import Config

# Configure your database
config :counter_2pc, Counter2PC.Repo,
  username: "postgres",
  password: "admin",
  hostname: "localhost",
  database: "counter_2pc_dev",
  stacktrace: true,
  port: 5433,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :counter_2pc, Counter2PCWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [
    ip: {127, 0, 0, 1},
    port: String.to_integer(System.get_env("PORT") || "2000")
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: false,
  secret_key_base: "V56ldMKatD508AwLXvY6qO248VoByx4Ji4QxpfMs/6y2BVHPMnU3ceFfgbasOcd0",
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
