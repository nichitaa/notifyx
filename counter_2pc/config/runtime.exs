import Config

if System.get_env("PHX_SERVER") do
  config :counter_2pc, Counter2PCWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      "Mj1ENB0Sqa/QHLUx1umXWvnvmBNayZyBWucJR5kTGJKonJxXzMndIEYtvyYMJjhK"

  port = String.to_integer(System.get_env("PORT") || "2000")

  config :counter_2pc, Counter2PCWeb.Endpoint,
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
