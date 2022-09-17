defmodule Durian.PlugUtils do
  import Plug.Conn

  def get_auth_token(conn), do: get_header_token(conn) || get_session(conn, :user_token)

  def halt_unauthorized_response(conn, error_message) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(:unauthorized, Jason.encode!(%{error: error_message, success: false}))
    |> halt()
  end

  ## Privates

  defp get_header_token(conn) do
    header_key = auth_header_key()

    case get_req_header(conn, header_key) do
      [token] -> token
      [] -> nil
    end
  end

  defp auth_header_key(), do: Application.fetch_env!(:durian, :auth_header_key)
end
