defmodule Harpoon.Repo do
  use Ecto.Repo,
    otp_app: :harpoon,
    adapter: Ecto.Adapters.SQLite3
end
