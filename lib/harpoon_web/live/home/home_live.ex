defmodule HarpoonWeb.HomeLive do
  @moduledoc false
  use HarpoonWeb, :live_view

  alias Harpoon.Contexts.Requests

  require Logger

  embed_templates("partials/*")

  @impl true
  def mount(%{"sid" => sid}, _, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Harpoon.PubSub, "requests:#{sid}")
    {:ok, stream_configure(socket, :requests, dom_id: &"requests-#{&1.id}")}
  end

  @impl true
  def mount(_, _, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"sid" => sid} = params, _uri, socket) do
    requests = Requests.list_by_sid(sid)

    socket =
      assign_state(socket, requests, sid, params["rid"])

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
    current = socket.assigns[:current]

    socket =
      socket
      |> stream_insert(:requests, req, at: 0)
      |> assign(:current, if(current, do: current, else: req))
      |> put_flash(:info, "Ahoy! A new request was hooked!")

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => <<"requests-" <> id>> = dom_id}, socket) do
    case Requests.delete_by_id(id) do
      {:ok, _} ->
        sid = socket.assigns[:sid]

        socket
        |> stream_delete_by_dom_id(:requests, dom_id)
        |> put_flash(:info, "#{id} deleted!")
        |> assign(:current, nil)
        |> push_navigate(to: ~p"/?sid=#{sid}")
        |> then(&{:noreply, &1})

      error ->
        Logger.error("delete error #{inspect(error)}")
        {:noreply, put_flash(socket, :error, "error deleting #{id}")}
    end
  end

  @impl true
  def handle_event("delete_all", _, socket) do
    sid = socket.assigns[:sid]

    case Requests.delete_all_by_sid(sid) do
      {:ok, deleted} ->
        {:noreply,
         socket
         |> stream(:requests, [], reset: true)
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
    |> stream(:requests, requests)
    |> assign(:sid, sid)
    |> assign(:rid, new_rid)
    |> assign(:current, current)
    |> assign(page_title: "[Harpoon] SID: #{sid}")
    |> then(&if(is_nil(rid) && new_rid, do: push_navigate(&1, to: ~p"/?sid=#{sid}&rid=#{new_rid}"), else: &1))
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
