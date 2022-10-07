defmodule JulikWeb.Router do
  use JulikWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", JulikWeb do
    pipe_through :api
    post "/register", RegisterController, :register
    get "/service_address/:service_name", RegisterController, :get_service_address
    delete "/:service_name", RegisterController, :remove_service
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: JulikWeb.Telemetry
    end
  end
end
