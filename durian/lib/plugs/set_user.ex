defmodule Durian.Plugs.SetUser do
  import Plug.Conn

  alias Durian.PlugUtils
  alias Durian.Cache

  def init(_params) do
  end

  # to get access to the %User struct use `conn.assigns[:user]`
  def call(conn, _params) do
    assign_user =
      if conn.assigns[:user] === nil do
        with token when not is_nil(token) <- PlugUtils.get_auth_token(conn),
             {:ok, user} <- Cache.get_user_from_cache_or_db(token) do
          {:ok, user}
        end
      end

    case assign_user do
      nil -> conn
      {:ok, user} -> assign(conn, :user, user)
    end
  end
end
