import Config

config :guava,
  # In this service cluster, only one Node can expose endpoints, 
  # and act as parent not and load-balance requests, other Nodes could process
  # requests via RPC
  enable_rest_api: String.to_integer(System.get_env("ENABLE_REST_API") || "0"),
  service_discovery_base_url: "http://localhost:8000",
  # test concurrent task limit with limit = 2, timeout = 5000
  concurent_task_limit: 2,
  terminate_worker_after: 5000

# Configures the endpoint
config :guava, GuavaWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GuavaWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Guava.PubSub,
  live_view: [signing_salt: "2a45NjIk"],
  # configuring Cowboy2Adapter: https://hexdocs.pm/phoenix/Phoenix.Endpoint.Cowboy2Adapter.html
  http: [
    transport_options: [
      # => increase for prod (I don't want to see that many processes in :observer.start)
      num_acceptors: 2,
      # => default
      max_connections: 16_384
    ]
  ]

# Configures the mailer
config :guava, Guava.Mailer, adapter: Swoosh.Adapters.Gmail

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, Swoosh.ApiClient.Finch

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# For Google OAuth
config :goth, json: File.read!("service_account.json")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
