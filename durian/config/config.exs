import Config

config :durian,
  ecto_repos: [Durian.Repo],
  generators: [binary_id: true],
  auth_header_key: "durian-token",
  service_discovery_base_url: "http://localhost:8000"

config :durian, Durian.PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    # Grafana host
    host: "http://localhost:3000",
    username: "admin",
    password: "admin",
    upload_dashboards_on_start: true,
    folder_name: "Durian (auth-service-dev) Dashboards",
    annotate_app_lifecycle: true
  ]

config :durian, Durian.Cache,
  stats: true,
  telemetry: true,
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
config :durian, DurianWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: DurianWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Durian.PubSub,
  live_view: [signing_salt: "u9TQM1zv"],
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
