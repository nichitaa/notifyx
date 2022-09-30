defmodule Acai.Services.Auth do
  alias Acai.ServicesAgent

  @recv_timeout 1000
  @login_endpoint "/api/users/login"

  def login_and_get_user(email, password) do
    dbg("email: #{email} password: #{password}")
    headers = ["Content-Type": "application/json"]
    options = [recv_timeout: @recv_timeout]
    body = Jason.encode!(%{email: email, password: password})

    with {:ok, base_url} <- base_url(),
         login_url <- base_url <> @login_endpoint,
         response <- HTTPoison.post(login_url, body, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "token" => token, "id" => user_id} <- Jason.decode!(body) do
      user = %{
        email: email,
        user_id: user_id,
        token: token
      }

      dbg(user)
      user
    else
      _ -> nil
    end
  end

  ## Privates

  defp base_url(), do: ServicesAgent.get_service_address("auth")
end
