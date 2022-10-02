defmodule AcaiWeb.UserController do
  use AcaiWeb, :controller
  alias Acai.Services.Auth

  def register(conn, %{"email" => email, "password" => password}) do
    case Auth.register_user(email, password) do
      {:ok, user_id} -> json(conn, %{success: true, user_id: user_id})
      {:error, error_data} -> json(conn, error_data)
    end
  end
end
