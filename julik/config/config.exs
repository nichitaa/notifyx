import Config

config :julik,
  gateway_base_url: "http://localhost:4000"

config :julik, JulikWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: JulikWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Julik.PubSub,
  live_view: [signing_salt: "NaC68GrA"],
  # configuring Cowboy2Adapter: https://hexdocs.pm/phoenix/Phoenix.Endpoint.Cowboy2Adapter.html
  http: [
    transport_options: [
      # => increase for prod (I don't want to see that many processes in :observer.start)
      num_acceptors: 2,
      # => default
      max_connections: 16_384
    ]
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
