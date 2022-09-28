defmodule GuavaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :guava

  @session_options [
    store: :cookie,
    key: "_guava_key",
    signing_salt: "fFyGm+iN"
  ]

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug GuavaWeb.Router
end
