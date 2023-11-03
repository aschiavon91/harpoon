defmodule HarpoonWeb.HomeLive do
  use HarpoonWeb, :live_view
  alias Harpoon.Storage.Requests

  @impl true
  def mount(params, %{"sid" => sid}, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Harpoon.PubSub, "requests:#{sid}")
    socket = assign_all(socket, sid, params["rid"])

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"sid" => sid} = params, _uri, socket) do
    rid = params["rid"]
    current = get_current_request(socket, rid)

    socket =
      socket
      |> assign(sid: sid)
      |> assign(rid: rid)
      |> assign(current: current)
      |> assign(page_title: "[Harpoon] SID: #{sid}")

    {:noreply, socket}
  end

  @impl true
  def handle_info(req, socket) do
    requests = socket.assigns[:requests] |> Kernel.||([]) |> then(&[req | &1])
    socket = assign(socket, :requests, requests)
    {:noreply, socket}
  end

  defp assign_all(socket, sid, rid) do
    current = get_current_request(socket, rid)

    socket
    |> assign(sid: sid)
    |> assign(rid: rid)
    |> assign(requests: Requests.list_by_sid(sid))
    |> assign(current: current)
    |> assign(page_title: "[Harpoon] SID: #{sid}")
  end

  defp get_current_request(socket, rid) do
    socket.assigns[:requests]
    |> Kernel.||([])
    |> Enum.find(&(&1.id == rid))
  end
end
