import Config

# Configure your database
config :durian, Durian.Repo,
  username: "postgres",
  password: "admin",
  port: 5433,
  hostname: "localhost",
  database: "durian_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :durian, DurianWeb.Endpoint,
  http: [
    ip: {127, 0, 0, 1},
    port: String.to_integer(System.get_env("PORT") || "5000")
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: false,
  secret_key_base: "IR126AswpfmxyPD8Hd01Lq+jKKxQIrdEDo9UZi6WatpL04OsGXeuGrTUTLB21wop",
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
