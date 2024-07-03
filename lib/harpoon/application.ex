defmodule Harpoon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Harpoon.Workers.CapturedRequestsWorker
  alias Harpoon.Workers.MigrationRunnerWorker

  @impl true
  def start(_type, _args) do
    children = [
      HarpoonWeb.Telemetry,
      Harpoon.Repo,
      MigrationRunnerWorker,
      {Phoenix.PubSub, name: Harpoon.PubSub},
      CapturedRequestsWorker,
      HarpoonWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Harpoon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HarpoonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
