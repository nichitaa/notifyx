import Config

config :kiwi,
  ecto_repos: [Kiwi.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :kiwi, KiwiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: KiwiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Kiwi.PubSub,
  live_view: [signing_salt: "Zy9DhRn9"],
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
