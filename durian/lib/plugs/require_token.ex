defmodule Durian.Plugs.RequireToken do
  import Plug.Conn
  alias Durian.Repo
  alias Durian.Auth.User

  def init(_params) do
  end

  def call(conn, params) do
    body = conn.body_params
    token = body[:token] || get_session(conn, :user_token)

    cond do
      token !== nil ->
        user = token && Repo.get_by(User, token: token)
        dbg(user)
        assign(conn, :user, user)

      true ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "missing required token"}))
        |> halt()
    end
  end
end
