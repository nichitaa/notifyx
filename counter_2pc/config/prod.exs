import Config

# Do not print debug messages in production
config :logger, level: :info

config :counter_2pc,
  ecto_repos: [Counter2PC.Repo],
  generators: [binary_id: true],
  auth_header_key: "durian-token",
  service_discovery_base_url: "http://julik:8000"

# Configure your database
config :counter_2pc, Counter2PC.Repo,
  username: System.get_env("PGUSER"),
  password: System.get_env("PGPASSWORD"),
  port: System.get_env("PGPORT"),
  hostname: System.get_env("PGHOST"),
  database: System.get_env("PGDATABASE"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configures the endpoint
config :counter_2pc, Counter2PCWeb.Endpoint, url: [host: "counter_2pc"]
