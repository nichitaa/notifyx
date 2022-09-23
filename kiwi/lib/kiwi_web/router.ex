defmodule KiwiWeb.Router do
  use KiwiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Kiwi.Plugs.Authenticate
  end

  scope "/api", KiwiWeb do
    pipe_through :api

    get "/topics", TopicController, :list
    get "/topics/:id", TopicController, :get_by_id
    post "/topics", TopicController, :create
    post "/topics/:id/status", TopicController, :update_status
    # resources "/notifications", NotificationController, except: [:new, :edit]
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: KiwiWeb.Telemetry
    end
  end
end
