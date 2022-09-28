defmodule KiwiWeb.Router do
  use KiwiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Kiwi.Plugs.Authenticate
  end

  scope "/api", KiwiWeb do
    pipe_through :api

    # Topics
    get "/topics", TopicController, :list
    get "/topics/:id", TopicController, :get_by_id
    post "/topics", TopicController, :create
    post "/topics/:id/status", TopicController, :update_status

    # Subscribers
    post "/subscribers/:topic_id", TopicSubscriberController, :subscribe
    get "/subscribers/:topic_id", TopicSubscriberController, :list_subscribers
    delete "/subscribers/:topic_id", TopicSubscriberController, :unsubscribe

    # Notifications
    post "/notifications", NotificationController, :create
    get "/notifications", NotificationController, :get_own_notifications
    post "/notifications/:id/seen", NotificationController, :update_status_to_seen
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: KiwiWeb.Telemetry
    end
  end
end
