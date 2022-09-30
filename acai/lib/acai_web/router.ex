defmodule AcaiWeb.Router do
  use AcaiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AcaiWeb do
    pipe_through :api
    post "/register_service", ServiceRegisterController, :register_service
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: AcaiWeb.Telemetry
    end
  end
end
