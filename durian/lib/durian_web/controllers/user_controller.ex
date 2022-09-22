defmodule DurianWeb.UserController do
  use DurianWeb, :controller

  alias Durian.Auth
  alias Durian.Cache
  # alias Durian.Auth.User

  action_fallback DurianWeb.FallbackController

  plug Durian.Plugs.RequireValidToken when action in [:list, :get_user, :logout]

  def list(conn, _params) do
    with {:ok, cached_users} <- Cache.get_users_list() do
      success_response(conn, "list.json", %{users: cached_users})
    else
      {:not_in_cache} ->
        users = Auth.list_users()
        Cache.add_users_list(users)
        success_response(conn, "list.json", %{users: users})
    end
  end

  def register(conn, _params) do
    body = conn.body_params

    with {:ok, user} <- Auth.register(body) do
      Cache.add_user(user)
      success_response(conn, "register.json", %{id: user.id}, :created)
    end
  end

  def get_user(conn, %{"id" => id}) do
    with {:ok, cached_user} <- Cache.get_user(id) do
      success_response(conn, "get_user.json", %{user: cached_user})
    else
      {:not_in_cache} ->
        case Auth.get_user(id) do
          nil ->
            {:error, :not_found}

          user ->
            Cache.add_user(user)
            success_response(conn, "get_user.json", %{user: user})
        end
    end
  end

  def login(conn, _params) do
    body = conn.body_params
    %{"email" => email, "password" => password} = body

    found_user = Auth.get_user_by_email_and_password(email, password)

    with user when not is_nil(user) <- found_user do
      case user.token do
        nil ->
          with {:ok, updated_user} <-
                 Auth.update_user_session_token(user) do
            conn
            |> put_session(:user_token, updated_user.token)
            |> success_response("login.json", %{user: updated_user})
          end

        _token ->
          success_response(conn, "login.json", %{user: user})
      end
    else
      nil -> {:error, :not_found}
    end
  end

  def logout(conn, _params) do
    user = conn.assigns[:user]

    with {:ok, updated_user} <-
           Auth.delete_user_session_token(user) do
      conn
      |> delete_session(:user_token)
      |> delete_session(:user)
      |> success_response("logout.json", %{user: updated_user})
    end
  end

  ## Privates 

  defp success_response(conn, view, assigns, status \\ :ok) do
    conn
    |> put_resp_content_type("application/json")
    |> put_status(status)
    |> render(view, assigns)
  end
end
