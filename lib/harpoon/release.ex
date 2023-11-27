defmodule Harpoon.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :harpoon

  @spec migrate(boolean()) :: :ok | no_return()
  def migrate(should_load_app \\ true) do
    if should_load_app do
      _ = load_app()
    end

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  def rollback(repo, version) do
    _ = load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    :ok = Application.load(@app)
  end
end
