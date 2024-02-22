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

  check_origin = host !== "localhost" && host !== "0.0.0.0" && host !== "127.0.0.1"

  origin_hosts =
    Enum.map(
      [
        %URI{host: host, scheme: scheme, port: port},
        %URI{host: "*.#{host}", scheme: scheme, port: port}
      ],
      &URI.to_string/1
    )

  config :harpoon, HarpoonWeb.Endpoint,
    url: [host: host || "0.0.0.0", port: port, scheme: scheme],
    server: System.get_env("PHX_SERVER", "true") == "true",
    check_origin: if(check_origin, do: origin_hosts, else: false),
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  cors_hosts = Enum.map(
    [
      %URI{host: host, scheme: scheme},
      %URI{host: "*.#{host}", scheme: scheme}
    ],
    &URI.to_string/1
  )

  config :cors_plug,
    origin: if(check_origin, do: cors_hosts, else: ["*"]),
    max_age: 86_400
end
