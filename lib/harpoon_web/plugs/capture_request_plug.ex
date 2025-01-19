defmodule HarpoonWeb.CaptureRequestPlug do
  @moduledoc false
  @behaviour Plug

  alias Phoenix.PubSub

  require Logger

  def init(_opts), do: []

  def call(%Plug.Conn{host: host} = conn, _) do
    endpoint_config = fetch_config!(:url)
    root_host = endpoint_config[:host]

    case extract_subdomain(host, root_host) do
      subdomain when byte_size(subdomain) > 0 ->
        handle_subdomain_request(conn, subdomain)

      _ ->
        conn
    end
  end

  defp handle_subdomain_request(conn, sid) do
    with true <- String.match?(sid, ~r/([a-z]+-)([a-z]+-)\d{2}/),
         {:ok, req, conn} <- conn_to_request(conn, sid) do
      PubSub.broadcast!(Harpoon.PubSub, "requests", req)

      conn
      |> Plug.Conn.send_resp(200, "")
      |> Plug.Conn.halt()
    else
      {:error, reason} ->
        Logger.error("Error capturing request reason #{inspect(reason)}")
        conn

      false ->
        conn
        |> Plug.Conn.send_resp(500, "Internal Server Error")
        |> Plug.Conn.halt()
    end
  end

  defp conn_to_request(conn, sid, acc \\ <<>>) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, conn} ->
        conn_data = parse_conn_data(conn, sid, acc <> body)
        adapter_data = parse_from_adapter_data(conn.adapter)
        req = Map.merge(conn_data, adapter_data)
        {:ok, req, conn}

      {:more, body, conn} ->
        conn_to_request(conn, sid, acc <> body)

      err ->
        err
    end
  end

  defp parse_conn_data(conn, sid, body) do
    %{
      sid: sid,
      path: conn.request_path,
      headers: Map.new(conn.req_headers),
      body: body,
      method: conn.method,
      query_params: conn.query_params,
      host: conn.host,
      cookies: conn.req_cookies
    }
  end

  defp parse_from_adapter_data({_, %{transport: transport, metrics: metrics}}) do
    remote_ip = transport.socket.span.start_metadata.remote_address || {127, 0, 0, 1}
    remote_port = transport.socket.span.start_metadata.remote_port || 0

    %{
      remote_ip: to_string(:inet_parse.ntoa(remote_ip)),
      remote_port: to_string(remote_port),
      body_length: metrics.req_body_bytes || 0,
      http_version: to_string(transport.version)
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
