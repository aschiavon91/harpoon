defmodule Harpoon.Repo.Migrations.AddRequestsTable do
  use Ecto.Migration

  def change do
    create table("requests", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :sid, :uuid, null: false
      add :path, :string, null: false
      add :method, :string, null: false
      add :host, :string, null: false
      add :headers, :jsonb, null: false
      add :body, :text, null: true
      add :remote_ip, :string
      add :remote_port, :string
      add :http_version, :string
      add :query_params, :jsonb
      add :cookies, :jsonb
      add :body_length, :integer

      timestamps(type: :utc_datetime_usec)
    end
  end
end
