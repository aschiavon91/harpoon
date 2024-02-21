# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :harpoon,
  ecto_repos: [Harpoon.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :harpoon, HarpoonWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: HarpoonWeb.ErrorHTML, json: HarpoonWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Harpoon.PubSub,
  live_view: [signing_salt: "Rl8aH79d"]

config :nanoid,
  size: 21,
  alphabet: "_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.5",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
