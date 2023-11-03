defmodule Harpoon.Repo do
  use Ecto.Repo,
    otp_app: :harpoon,
    adapter: Ecto.Adapters.Postgres
end
