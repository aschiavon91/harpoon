defmodule Harpoon.Models.Request do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  @fields ~w(
    sid
    path
    method
    headers
    body
    query_params
    cookies
    host
    remote_ip
    remote_port
    http_version
    body_length
  )a

  @required_fields ~w(
    sid
    path
    method
    headers
    host
  )a

  @timestamps_opts [type: :utc_datetime_usec]

  @derive Jason.Encoder
  @primary_key {:id, :string, autogenerate: false}
  schema "requests" do
    field :sid, :string
    field :path, :string
    field :method, :string
    field :headers, :map
    field :body, :string
    field :query_params, :map
    field :cookies, :map
    field :host, :string
    field :remote_ip, :string
    field :remote_port, :string
    field :http_version, :string
    field :body_length, :integer

    timestamps()
  end

  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> put_change(:id, Nanoid.generate())
    |> validate_format(:sid, ~r/^[a-z]+-[a-z]+-\d{2}$/)
  end
end
