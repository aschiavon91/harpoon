defmodule Harpoon.Requests do
  @moduledoc false
  import Ecto.Query

  alias Harpoon.Repo
  alias Harpoon.Requests.Request
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
      {:ok, req} -> broadcast(req.sid, {:created, req})
      err -> err
    end
  end

  def delete_by_sid_and_id(sid, req_id) do
    Request
    |> where([r], r.id == ^req_id and r.sid == ^sid)
    |> Repo.delete_all()
    |> case do
      {_, _} -> broadcast(sid, {:deleted, req_id})
      err -> err
    end
  end

  def delete(req) do
    req
    |> Repo.delete()
    |> case do
      {:ok, _} -> broadcast(req.sid, {:deleted, req})
      err -> err
    end
  end

  def delete_all_by_sid(sid) do
    Request
    |> where(sid: ^sid)
    |> Repo.delete_all()
    |> case do
      {deleted, _} -> broadcast(sid, {:all_deleted, deleted})
      err -> err
    end
  end

  def count_grouped_by_sid do
    Request
    |> group_by(:sid)
    |> select([r], %{count: count(r.id), sid: r.sid})
    |> Repo.all()
  end

  defp broadcast(sid, data) do
    Harpoon.PubSub
    |> PubSub.broadcast("requests:#{sid}", data)
    |> case do
      :ok -> {:ok, data}
      err -> err
    end
  end
end
