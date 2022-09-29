import Config

config :kiwi,
  ecto_repos: [Kiwi.Repo],
  generators: [binary_id: true],
  auth_service_base_url: "http://localhost:5000/api/users"

config :kiwi, Kiwi.Cache,
  # GC interval for pushing new generation: 12 hrs
  gc_interval: :timer.hours(12),
  # Max 1 million entries in cache
  max_size: 1_000_000,
  # Max 1 GB of memory
  allocated_memory: 1_000_000_000,
  # GC min timeout: 10 sec
  gc_cleanup_min_timeout: :timer.seconds(10),
  # GC max timeout: 10 min
  gc_cleanup_max_timeout: :timer.minutes(10)

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
