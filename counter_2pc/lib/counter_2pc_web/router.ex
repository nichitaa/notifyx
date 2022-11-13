defmodule Counter2PCWeb.Router do
  use Counter2PCWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Counter2PCWeb do
    pipe_through :api

    post "/prepare_increment_2pc/:user_id", CounterController, :prepare_increment_2pc
    post "/commit_2pc/:user_id", CounterController, :commit_2pc
    delete "/rollback_2pc/:user_id", CounterController, :rollback_2pc
    get "/counter/:user_id", CounterController, :get_counter
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: Counter2PCWeb.Telemetry
    end
  end
end
