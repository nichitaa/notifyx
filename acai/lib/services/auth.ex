defmodule Acai.Services.Auth do
  def login_and_get_user(email, password) do

    dbg("email: #{email} password: #{password}")
    url = base_url() <> "/login"
    headers = ["Content-Type": "application/json"]
    options = [recv_timeout: 1500]
    body = Jason.encode!(%{email: email, password: password})
    response = HTTPoison.post(url, body, headers, options)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
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

  defp base_url(), do: Application.fetch_env!(:acai, :auth_service_base_url)
end
