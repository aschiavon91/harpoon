import Config

if config_env() == :prod do
  user_home = System.fetch_env!("HOME")

  config :harpoon, Harpoon.Repo,
    database: System.get_env("DATABASE_FILE", "#{user_home}/.harpoon/harpoon_prod.sqlite"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  generated_secret_key_base = 64 |> :crypto.strong_rand_bytes() |> Base.encode64(padding: false) |> binary_part(0, 64)
  secret_key_base = System.get_env("SECRET_KEY_BASE", generated_secret_key_base)

  host = System.get_env("PHX_HOST")
  port = String.to_integer(System.get_env("PORT", "4000"))
  scheme = "http"

  uri = %URI{host: host, port: port, scheme: scheme}
  uri_wildcard = %URI{host: "*.#{host}", port: port, scheme: scheme}
  host_uris = [URI.to_string(uri), URI.to_string(uri_wildcard)]

  config :harpoon, HarpoonWeb.Endpoint,
    url: [host: host || "0.0.0.0", port: port, scheme: scheme],
    server: System.get_env("PHX_SERVER", "true") == "true",
    check_origin: if(host, do: host_uris, else: false),
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  config :cors_plug,
    origin: if(host, do: host_uris, else: ["*"]),
    max_age: 86_400
end
