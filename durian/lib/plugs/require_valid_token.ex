defmodule Durian.Plugs.RequireValidToken do
  import Plug.Conn
  alias Durian.Repo
  alias Durian.Auth.User
  alias Durian.PlugUtils

  def init(_params) do
  end

  def call(conn, _params) do
    with token when not is_nil(token) <- PlugUtils.get_auth_token(conn),
         user when not is_nil(user) <- Repo.get_by(User, token: token) do
      assign(conn, :user, user)
    else
      _ -> PlugUtils.halt_unauthorized_response(conn, "missing on invalid auth token")
    end
  end
end
