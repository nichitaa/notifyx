defmodule DurianWeb.Router do
  use DurianWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Durian.Plugs.SetUser
  end

  scope "/api", DurianWeb do
    pipe_through :api

    get "/users", UserController, :list
    get "/users/:id", UserController, :get_user
    post "/users", UserController, :register
    post "/users/login", UserController, :login
  end

  # Enables LiveDashboard only for development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: DurianWeb.Telemetry
    end
  end
end
