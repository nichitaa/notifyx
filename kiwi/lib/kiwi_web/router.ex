defmodule KiwiWeb.Router do
  use KiwiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", KiwiWeb do
    pipe_through :api

    resources "/topics", TopicController, except: [:new, :edit]
    resources "/notifications", NotificationController, except: [:new, :edit]
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: KiwiWeb.Telemetry
    end
  end
end
