# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :netronix_geo,
  ecto_repos: [NetronixGeo.Repo]

# Configures the auth module based on Guardian lib
config :netronix_geo, NetronixGeoWeb.Auth.Guardian,
  issuer: "NetronixGeo",
  secret_key: "#{Mix.env()}"

# Configures the endpoint
config :netronix_geo, NetronixGeoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ee6vaTcxBBeyzEzBhpypzce6rm47q9x0/QzT3sYRMl6gGSwxigTTgiuJNdxVT4KH",
  render_errors: [view: NetronixGeoWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: NetronixGeo.PubSub,
  live_view: [signing_salt: "WFHRyGGs"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
