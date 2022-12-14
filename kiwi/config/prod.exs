import Config

config :kiwi,
  ecto_repos: [Kiwi.Repo],
  generators: [binary_id: true],
  service_discovery_base_url: "http://julik:8000"

config :kiwi, Kiwi.PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    host: "http://grafana:3000",
    username: "admin",
    password: "admin",
    upload_dashboards_on_start: true,
    folder_name: "Kiwi (kiwi-service-prod) Dashboards",
    annotate_app_lifecycle: true
  ]

config :kiwi, Kiwi.Repo,
  username: System.get_env("PGUSER"),
  password: System.get_env("PGPASSWORD"),
  port: System.get_env("PGPORT"),
  hostname: System.get_env("PGHOST"),
  database: System.get_env("PGDATABASE"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configures the endpoint
config :kiwi, KiwiWeb.Endpoint, url: [host: "kiwi"]

# Do not print debug messages in production
config :logger, level: :info
