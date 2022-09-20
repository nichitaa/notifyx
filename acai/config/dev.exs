import Config

config :acai, AcaiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 5000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "oqS3klBgCX1NOL+ixhaUtgBfbBtVKhJPu38qI+icITd8lhDUk9c6b9AuDTagc9jC",
  watchers: []

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
