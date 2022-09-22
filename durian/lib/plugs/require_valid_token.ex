defmodule Durian.Plugs.RequireValidToken do
  import Plug.Conn
  alias Durian.Repo
  alias Durian.Auth.User
  alias Durian.PlugUtils
  alias Durian.Cache

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] == nil do
      with token when not is_nil(token) <- PlugUtils.get_auth_token(conn),
           {:ok, user} <- Cache.get_user_from_cache_or_db(token) do
        assign(conn, :user, user)
      else
        _ -> PlugUtils.halt_unauthorized_response(conn, "missing on invalid auth token")
      end
    else
      conn
    end
  end
end
