import Config

config :julik, JulikWeb.Endpoint,
  http: [
    ip: {127, 0, 0, 1},
    port: String.to_integer(System.get_env("PORT") || "8000")
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: false,
  secret_key_base: "55DhlDBl+Ff7wBreGw1vllaock6u/g8g0cZyhpvroL/s4FrGt1HQNuuIFBkwT5/z",
  watchers: []

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
