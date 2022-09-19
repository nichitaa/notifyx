# General application configuration
import Config

config :acai,
  ecto_repos: [Acai.Repo],
  generators: [binary_id: true],
  auth_service_base_url: "http://localhost:4000/api/users"

# Configures the endpoint
config :acai, AcaiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AcaiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Acai.PubSub,
  live_view: [signing_salt: "z6gNEszW"],
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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
