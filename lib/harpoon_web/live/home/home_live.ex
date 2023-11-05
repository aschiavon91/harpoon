defmodule HarpoonWeb.HomeLive do
  @moduledoc false
  use HarpoonWeb, :live_view

  alias Harpoon.Contexts.Requests

  require Logger

  embed_templates("partials/*")

  @impl true
  def mount(%{"sid" => sid} = params, _, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Harpoon.PubSub, "requests:#{sid}")
    requests = Requests.list_by_sid(sid)
    socket = assign_state(socket, requests, sid, params["rid"])
    {:ok, socket}
  end

  @impl true
  def mount(_, _, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"sid" => sid} = params, _uri, socket) do
    requests = socket.assigns[:requests]
    socket = assign_state(socket, requests, sid, params["rid"])
    {:noreply, socket}
  end

  @impl true
  def handle_params(_, _, socket) do
    sid = Ecto.UUID.generate()

    socket =
      socket
      |> assign(:sid, sid)
      |> redirect(to: ~p"/?sid=#{sid}")
      |> assign(page_title: "[Harpoon] SID: #{sid}")

    {:noreply, socket}
  end

  @impl true
  def handle_info(req, socket) do
    requests = socket.assigns[:requests] || []
    current = socket.assigns[:current]

    socket =
      socket
      |> assign(:requests, [req | requests])
      |> assign(:current, if(current, do: current, else: req))
      |> put_flash(:info, "Ahoy! A new request was hooked!")

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    requests = socket.assigns[:requests]
    idx = Enum.find_index(requests, &(&1.id == id))

    with {%{} = to_delete, requests} <- List.pop_at(requests, idx),
         {:ok, _} <- Requests.delete(to_delete) do
      sid = socket.assigns[:sid]

      socket =
        socket
        |> put_flash(:info, "#{id} deleted!")
        |> assign(:requests, requests)
        |> assign(:current, nil)
        |> push_navigate(to: ~p"/?sid=#{sid}")

      {:noreply, socket}
    else
      error ->
        Logger.error("delete error #{inspect(error)}")
        {:noreply, put_flash(socket, :error, "error deleting #{id}")}
    end
  end

  @impl true
  def handle_event("delete_all", _, %{assigns: %{requests: []}} = socket) do
    {:noreply, put_flash(socket, :warn, "nothing to delete")}
  end

  @impl true
  def handle_event("delete_all", _, socket) do
    sid = socket.assigns[:sid]

    case Requests.delete_all_by_sid(sid) do
      {:ok, deleted} ->
        {:noreply,
         socket
         |> assign(:requests, [])
         |> assign(:current, nil)
         |> then(&if(deleted > 0, do: put_flash(&1, :info, "all requests deleted!"), else: &1))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "error deleting all requests")}
    end
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
