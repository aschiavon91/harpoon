defmodule Harpoon.Contexts.Requests do
  @moduledoc false
  import Ecto.Query

  alias Harpoon.Models.Request
  alias Harpoon.Repo
  alias Phoenix.PubSub

  def list_by_sid(sid) do
    Request
    |> where(sid: ^sid)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create(params) do
    params
    |> Request.changeset()
    |> Repo.insert()
    |> case do
      {:ok, req} -> broadcast(req)
      err -> err
    end
  end

  def delete(request) do
    Repo.delete(request)
  end

  def delete_all_by_sid(sid) do
    Request
    |> where(sid: ^sid)
    |> Repo.delete_all()
    |> case do
      {deleted, _} -> {:ok, deleted}
      err -> err
    end
  end

  defp broadcast(req) do
    Harpoon.PubSub
    |> PubSub.broadcast("requests:#{req.sid}", req)
    |> case do
      :ok -> {:ok, req}
      err -> err
    end
  end
end
