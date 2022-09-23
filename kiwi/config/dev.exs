import Config

config :kiwi, Kiwi.Repo,
  username: "postgres",
  password: "admin",
  port: 5433,
  hostname: "localhost",
  database: "kiwi_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10


config :kiwi, KiwiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 9000],
  check_origin: false,
  code_reloader: true,
  debug_errors: false,
  secret_key_base: "VwBcIb3CvvGDe/EF4LLa4BZU1eR8shahC7gx57woZmuiYIdKnxH+S4sXUacrEmuY",
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
