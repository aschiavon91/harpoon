defmodule Harpoon.Repo.Migrations.CreateRequestsSidIndex do
  use Ecto.Migration

  def change do
    create_if_not_exists index(:requests, [:sid])
  end
end
