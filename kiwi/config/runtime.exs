import Config

if System.get_env("PHX_SERVER") do
  config :kiwi, KiwiWeb.Endpoint, server: true
end

if config_env() == :prod do

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      "Mj2ENB0Sqa/QHLUx1umXWvnvmBNayZxBWucJR5kTGJKonJxXzMndIEYtvyYMJjhK"

  # host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "6000")

  config :kiwi, KiwiWeb.Endpoint,
    # url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
