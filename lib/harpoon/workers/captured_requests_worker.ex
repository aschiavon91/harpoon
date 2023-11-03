defmodule Harpoon.Workers.CapturedRequestsWorker do
  @moduledoc false
  use GenServer

  alias Harpoon.Storage.Requests

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    case Phoenix.PubSub.subscribe(Harpoon.PubSub, "captured_requests") do
      :ok -> {:ok, []}
      err -> err
    end
  end

  @impl true
  def handle_info(req, state) do
    case Requests.create(req) do
      {:ok, _} -> :ok
      {:error, reason} -> Logger.error("#{__MODULE__}.handle_info error #{inspect(reason)}")
    end

    {:noreply, state}
  end
end
