defmodule HarpoonWeb.Plugs.CaptureRequestPlug do
  @moduledoc false
  @behaviour Plug

  alias Phoenix.PubSub

  require Logger

  def init(opts), do: opts

  def call(%Plug.Conn{path_info: path_info} = conn, _) do
    with {:ok, sid} <- Ecto.UUID.cast(List.first(path_info)),
         {:ok, req, conn} <- conn_to_request(conn, sid) do
      PubSub.broadcast!(Harpoon.PubSub, "captured_requests", req)

      conn
      |> Plug.Conn.send_resp(200, "")
      |> Plug.Conn.halt()
    else
      :error ->
        conn

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
              path: parse_path(conn.request_path, sid),
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

  defp parse_from_adapter_data(
         {Plug.Cowboy.Conn, %{version: version, peer: {peer_ip, peer_port}, body_length: body_length}}
       ) do
    %{
      remote_ip: to_string(:inet_parse.ntoa(peer_ip)),
      remote_port: to_string(peer_port),
      body_length: body_length,
      http_version: to_string(version)
    }
  end

  defp parse_path(path, sid) do
    path
    |> String.replace("/#{sid}", "")
    |> case do
      "" -> "/"
      other -> other
    end
  end
end
