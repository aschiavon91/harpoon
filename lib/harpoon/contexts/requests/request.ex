defmodule Harpoon.Requests.Request do
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

  @derive JSON.Encoder
  @primary_key {:id, :string, autogenerate: false}
  schema "requests" do
    field :sid, :string
    field :path, :string
    field :method, :string
    field :headers, :map
    field :body, :binary
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
    |> validate_format(:sid, ~r/([a-z]+-)([a-z]+-)\d{2}/)
  end

  def get_file_type(body) do
    cond do
      json?(body) -> {:ok, :json}
      xml?(body) -> {:ok, :xml}
      html?(body) -> {:ok, :html}
      text?(body) -> {:ok, :text}
      true -> get_file_extension(body)
    end
  end

  defp get_file_extension(body) do
    body
    |> MagicNumber.detect()
    |> case do
      {:ok, {:image, ext}} -> {:ok, ext}
      {:ok, {:application, :zip}} -> {:error, :invalid}
      {:ok, {:application, :gzip}} -> {:error, :invalid}
      {:ok, {:application, ext}} -> {:ok, ext}
      :error -> {:error, :unknown}
    end
  end

  defp json?(data) do
    _ = JSON.decode!(data)
    true
  rescue
    _ -> false
  end

  defp xml?(data) do
    data =~ ~r/^<\?/
  end

  defp html?(data) do
    data =~ ~r/^</
  end

  defp text?(data) do
    String.valid?(data)
  end
end
