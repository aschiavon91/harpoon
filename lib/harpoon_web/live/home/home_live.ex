defmodule HarpoonWeb.HomeLive do
  @moduledoc false
  use HarpoonWeb, :live_view

  alias Harpoon.Contexts.Requests

  @impl true
  def mount(params, %{"sid" => sid}, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Harpoon.PubSub, "requests:#{sid}")
    requests = Requests.list_by_sid(sid)
    socket = assign_state(socket, requests, sid, params["rid"])
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"sid" => sid} = params, _uri, socket) do
    requests = socket.assigns[:requests]
    socket = assign_state(socket, requests, sid, params["rid"])
    {:noreply, socket}
  end

  @impl true
  def handle_info(req, socket) do
    requests = socket.assigns[:requests] |> Kernel.||([]) |> then(&[req | &1])
    socket = assign(socket, :requests, requests)
    {:noreply, socket}
  end

  defp assign_state(socket, requests, sid, rid) do
    current = get_current_request(requests, rid)
    new_rid = Map.get(current || %{}, :id)

    socket
    |> assign(:sid, sid)
    |> assign(:rid, new_rid)
    |> assign(:requests, requests)
    |> assign(:current, current)
    |> assign(page_title: "[Harpoon] SID: #{sid}")
    |> then(&if(new_rid && is_nil(rid), do: push_navigate(&1, to: ~p"/?sid=#{sid}&rid=#{new_rid}"), else: &1))
  end

  defp get_current_request(requests, nil) do
    requests
    |> Kernel.||([])
    |> List.first()
  end

  defp get_current_request(requests, rid) do
    requests
    |> Kernel.||([])
    |> Enum.find(&(&1.id == rid))
  end
end
