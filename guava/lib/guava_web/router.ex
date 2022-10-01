defmodule GuavaWeb.Router do
  use GuavaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Guava.Plugs.ValidateNodeEnableRestApi
    plug Guava.Plugs.Authenticate
  end

  scope "/api", GuavaWeb do
    pipe_through :api
    post "/send_mail", MailController, :send_mail
  end
end
