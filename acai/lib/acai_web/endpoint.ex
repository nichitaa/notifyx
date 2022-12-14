defmodule AcaiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :acai

  socket "/socket", AcaiWeb.NotificationSocket,
    websocket: true,
    longpoll: false

  @session_options [
    store: :cookie,
    key: "_acai_key",
    signing_salt: "RMUwdUPp"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug PromEx.Plug, prom_ex_module: Acai.PromEx

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  # origin: "http://127.0.0.1:3333" would be a more secure option
  plug CORSPlug, origin: "*"
  plug AcaiWeb.Router
end
