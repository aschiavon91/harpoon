defmodule HarpoonWeb.Plugs.CaptureRequestPlug do
  @moduledoc false
  @behaviour Plug

  alias Phoenix.PubSub

  require Logger

  def init(_opts), do: []

  def call(%Plug.Conn{host: host} = conn, _) do
    root_host = fetch_config!(:url)[:host]

    case extract_subdomain(host, root_host) do
      subdomain when byte_size(subdomain) > 0 ->
        handle_subdomain_request(conn, subdomain)

      _ ->
        conn
    end
  end

  defp handle_subdomain_request(conn, "www"), do: conn

  defp handle_subdomain_request(conn, sid) do
    case conn_to_request(conn, sid) do
      {:ok, req, conn} ->
        PubSub.broadcast!(Harpoon.PubSub, "captured_requests", req)

        conn
        |> Plug.Conn.send_resp(200, "")
        |> Plug.Conn.halt()

      {:error, reason} ->
        Logger.error("Error capturing request reason #{inspect(reason)}")
        conn
    end
  end

  defp conn_to_request(conn, sid) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, conn} ->
        req =
          Map.merge(
            %{
              sid: sid,
              path: conn.request_path,
              headers: Map.new(conn.req_headers),
              body: body,
              method: conn.method,
              query_params: conn.query_params,
              host: conn.host,
              cookies: conn.req_cookies
            },
            parse_from_adapter_data(conn.adapter)
          )

        {:ok, req, conn}

      err ->
        err
    end
  end

  defp parse_from_adapter_data({_, %{version: version, peer: {peer_ip, peer_port}, body_length: body_length}}) do
    %{
      remote_ip: to_string(:inet_parse.ntoa(peer_ip)),
      remote_port: to_string(peer_port),
      body_length: body_length,
      http_version: to_string(version)
    }
  end

  defp parse_from_adapter_data({_, %{http_protocol: http_protocol, peer_data: %{port: peer_port, address: peer_ip}}}) do
    version =
      http_protocol
      |> to_string()
      |> String.split("/")
      |> List.last()

    %{
      remote_ip: to_string(:inet_parse.ntoa(peer_ip)),
      remote_port: to_string(peer_port),
      body_length: 0,
      http_version: version
    }
  end

  defp extract_subdomain(host, root_host) do
    String.replace(host, ~r/.?#{root_host}/, "")
  end

  defp fetch_config!(cfg_name) do
    :harpoon
    |> Application.fetch_env!(HarpoonWeb.Endpoint)
    |> Keyword.fetch!(cfg_name)
  end
end
