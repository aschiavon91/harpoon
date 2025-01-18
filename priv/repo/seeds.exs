# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Harpoon.Repo.insert!(%Harpoon.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Harpoon.Repo
alias Harpoon.Requests.Request

sid = "5bd5493b-96d7-4648-ba7b-5358978e6713"

[
  %{
    sid: sid,
    path: "/test",
    method: "GET",
    body: nil,
    headers: %{"Content-Type" => "application/json"}
  },
  %{
    sid: sid,
    path: "/test",
    method: "POST",
    body: ~s/{"name": "user"}/,
    headers: %{"Content-Type" => "application/json"}
  },
  %{
    sid: sid,
    path: "/test/1",
    method: "GET",
    body: nil,
    headers: %{"Content-Type" => "application/json"}
  }
]
|> Enum.map(&Request.changeset/1)
|> Enum.map(&Repo.insert/1)
