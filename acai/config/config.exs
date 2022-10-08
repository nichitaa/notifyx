import Config

config :acai,
  service_discovery_base_url: "http://localhost:8000"

config :acai, Acai.CircuitBreaker,
  # seconds
  reset_timeout: 5,
  # service_name: threshold (nr of 500/timeout service responses per timeframe)
  auth: 100,
  mail: 100,
  generator: 100,
  persist: 200

# Configures the endpoint
config :acai, AcaiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AcaiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Acai.PubSub,
  live_view: [signing_salt: "HQhnTQfn"],
  # configuring Cowboy2Adapter: https://hexdocs.pm/phoenix/Phoenix.Endpoint.Cowboy2Adapter.html
  http: [
    transport_options: [
      # => increase for prod (I don't want to see that many processes in :observer.start)
      num_acceptors: 2,
      # => default
      max_connections: 16_384
    ]
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
