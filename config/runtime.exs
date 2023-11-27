import Config

if config_env() == :prod do
  user_home = System.fetch_env!("HOME")

  config :harpoon, Harpoon.Repo,
    database: System.get_env("DATABASE_FILE", "#{user_home}/.harpoon/harpoon_prod.sqlite"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  generated_secret_key_base = 64 |> :crypto.strong_rand_bytes() |> Base.encode64(padding: false) |> binary_part(0, 64)
  secret_key_base = System.get_env("SECRET_KEY_BASE", generated_secret_key_base)

  host = System.get_env("PHX_HOST", "0.0.0.0")
  port = String.to_integer(System.get_env("PORT", "4000"))

  config :harpoon, HarpoonWeb.Endpoint,
    url: [host: host, port: port, scheme: "http"],
    server: System.get_env("PHX_SERVER", "true") == "true",
    check_origin: false,
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
