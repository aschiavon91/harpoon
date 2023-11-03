defmodule Harpoon.Repo.Migrations.AddRequestsTable do
  use Ecto.Migration

  def change do
    create table("requests", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :sid, :uuid, null: false
      add :path, :string, null: false
      add :method, :string, null: false
      add :headers, :jsonb, null: false
      add :body, :text, null: true

      timestamps(type: :utc_datetime_usec)
    end
  end
end
