defmodule Harpoon.Models.Request do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]

  @derive Jason.Encoder
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "requests" do
    field :sid, Ecto.UUID
    field :path, :string
    field :method, :string
    field :headers, :map
    field :body, :string

    timestamps()
  end

  def changeset(struct \\ %__MODULE__{}, params) do
    cast(struct, params, ~w(sid path method headers body)a)
  end
end
