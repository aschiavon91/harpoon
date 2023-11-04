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
        req = %{
          sid: sid,
          path: parse_path(conn.request_path, sid),
          method: conn.method,
          headers: Map.new(conn.req_headers),
          body: body
        }

        {:ok, req, conn}

      err ->
        err
    end
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
