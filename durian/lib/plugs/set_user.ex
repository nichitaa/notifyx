defmodule Durian.Plugs.SetUser do
  import Plug.Conn

  alias Durian.Repo
  alias Durian.Auth.User

  def init(_params) do
  end

  # to get access to the %User struct use `conn.assigns[:user]`
  def call(conn, _params) do
    body = conn.body_params

    if conn.assigns[:user] do
      conn
    else
      token = body[:token] || get_session(conn, :user_token)

      cond do
        user = token && Repo.get_by(User, token: token) ->
          assign(conn, :user, user)

        true ->
          assign(conn, :user, nil)
      end
    end
  end
end
