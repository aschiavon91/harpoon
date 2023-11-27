defmodule HarpoonWeb.SessionsLive do
  @moduledoc false
  use HarpoonWeb, :live_view

  alias Harpoon.Contexts.Requests

  embed_templates("partials/*")

  @impl true
  def mount(_params, _session, socket) do
    sessions = Requests.count_grouped_by_sid()
    {:ok, assign(socket, :sessions, sessions)}
  end
end
