defmodule HarpoonWeb.SessionsLive do
  @moduledoc false
  use HarpoonWeb, :live_view

  alias Harpoon.Requests

  embed_templates("partials/*")

  @impl true
  def mount(_params, _session, socket) do
    sessions = Requests.count_grouped_by_sid()
    {:ok, assign(socket, :sessions, sessions)}
  end

  @impl true
  def handle_event("delete", %{"sid" => sid}, socket) do
    sessions = Enum.reject(socket.assigns.sessions, &(&1.sid == sid))

    sid
    |> Requests.delete_all_by_sid()
    |> case do
      {:ok, _} -> {:noreply, assign(socket, :sessions, sessions)}
      {:error, _} -> {:noreply, socket}
    end
  end
end
