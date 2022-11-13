import Config

config :counter_2pc,
  namespace: Counter2PC,
  ecto_repos: [Counter2PC.Repo],
  generators: [binary_id: true],
  service_discovery_base_url: "http://localhost:8000"

# Configures the endpoint
config :counter_2pc, Counter2PCWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: Counter2PCWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Counter2PC.PubSub,
  live_view: [signing_salt: "vXYpT9bd"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
