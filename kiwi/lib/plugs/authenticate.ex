defmodule Kiwi.Plugs.Authenticate do
  import Plug.Conn

  alias Kiwi.Services

  def init(_params) do
  end

  def call(conn, _params) do
    response = Services.Auth.get_user(conn)

    case response do
      {:error, nil} ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> send_resp(:unauthorized, Jason.encode!(%{error: "unauthorized", success: false}))
        |> halt()

      {:ok, user} ->
        assign(conn, :user, user)

      unhandled ->
        raise("Error: unhandled case #{inspect(unhandled)}")
    end
  end
end
