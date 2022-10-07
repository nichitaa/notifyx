defmodule Acai.Services.Auth do
  alias Acai.ServicesAgent
  alias Acai.Utils.ReqUtils

  @recv_timeout 2000
  @login_endpoint "/api/users/login"
  @get_users_endpoint "/api/users"
  @register_user_endpoint "/api/users"

  def login_and_get_user(email, password) do
    dbg("email: #{email} password: #{password}")
    headers = ["Content-Type": "application/json"]
    options = get_options()
    body = Jason.encode!(%{email: email, password: password})

    request_fn =
      with {:ok, base_url} <- base_url(),
           login_url <- base_url <> @login_endpoint do
        {:ok, fn -> HTTPoison.post(login_url, body, headers, options) end}
      end

    response =
      with {:ok, req_fn} <- request_fn do
        ReqUtils.auto_retry(req_fn)
      end

    with {:ok, json} <- response,
         %{"success" => true, "token" => token, "id" => user_id} = json do
      %{
        email: email,
        user_id: user_id,
        token: token
      }
    else
      {:error, _error} -> nil
    end
  end

  def get_all_users(socket) do
    headers = get_headers(socket)
    options = get_options()

    with {:ok, base_url} <- base_url(),
         get_users_url <- base_url <> @get_users_endpoint,
         response <- HTTPoison.get(get_users_url, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => data} <- Jason.decode!(body) do
      {:ok, data}
    else
      error_data -> {:error, error_data}
    end
  end

  def register_user(email, password) do
    headers = ["content-type": "application/json"]
    options = get_options()
    body = Jason.encode!(%{email: email, password: password})

    with {:ok, base_url} <- base_url(),
         register_user_endpoint <- base_url <> @register_user_endpoint,
         response <- HTTPoison.post(register_user_endpoint, body, headers, options),
         {:ok, %HTTPoison.Response{status_code: 201, body: body}} <- response,
         %{"success" => true, "id" => user_id} <- Jason.decode!(body) do
      {:ok, user_id}
    else
      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, Jason.decode!(body)}

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        {:error, %{success: false, error: "timeout"}}

      error_data ->
        {:error, error_data}
    end
  end

  ## Privates

  defp get_options(), do: [recv_timeout: @recv_timeout]

  defp get_headers(socket),
    do: [
      "content-type": "application/json",
      "durian-token": socket.assigns.user.token
    ]

  defp base_url(), do: ServicesAgent.get_service_address("auth")
end
