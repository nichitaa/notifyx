defmodule Durian.Plugs.SetUser do
  import Plug.Conn

  alias Durian.Repo
  alias Durian.Auth.User
  alias Durian.PlugUtils

  def init(_params) do
  end

  # to get access to the %User struct use `conn.assigns[:user]`
  def call(conn, _params) do
    with token when not is_nil(token) <- PlugUtils.get_auth_token(conn),
         user when not is_nil(user) <- Repo.get_by(User, token: token) do
      assign(conn, :user, user)
    else
      _ -> assign(conn, :user, nil)
    end
  end
end
