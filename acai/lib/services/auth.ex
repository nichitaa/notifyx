defmodule Acai.Services.Auth do
  alias Acai.ServicesAgent
  alias Acai.Utils.ReqUtils
  alias Acai.CircuitBreaker

  @recv_timeout 2000
  @service_name "auth"
  @login_endpoint "/api/users/login"
  @get_users_endpoint "/api/users"
  @register_user_endpoint "/api/users"

  def login_and_get_user(email, password) do
    dbg("email: #{email} password: #{password}")
    headers = ["Content-Type": "application/json"]
    options = get_options()
    body = Jason.encode!(%{email: email, password: password})

    with {:ok, base_url} <- base_url(),
         login_url <- base_url <> @login_endpoint,
         request_fn <- fn -> HTTPoison.post(login_url, body, headers, options) end,
         {:ok, json} <- ReqUtils.auto_retry(request_fn),
         %{"success" => true, "token" => token, "id" => user_id} = json do
      %{
        email: email,
        user_id: user_id,
        token: token
      }
    else
      {:retry_error, _} ->
        CircuitBreaker.add_service_error(@service_name)
        nil

      _ ->
        nil
    end
  end

  def get_all_users(socket) do
    headers = get_headers(socket)
    options = get_options()

    with {:ok, base_url} <- base_url(),
         get_users_url <- base_url <> @get_users_endpoint,
         request_fn <- fn -> HTTPoison.get(get_users_url, headers, options) end,
         {:ok, json} <- ReqUtils.auto_retry(request_fn),
         %{"success" => true, "data" => data} <- json do
      {:ok, data}
    else
      {:retry_error, _} ->
        CircuitBreaker.add_service_error(@service_name)
        {:error, "could not receive from auth service"}

      error_data ->
        {:error, error_data}
    end
  end

  def register_user(email, password) do
    headers = ["content-type": "application/json"]
    options = get_options()
    body = Jason.encode!(%{email: email, password: password})

    with {:ok, base_url} <- base_url(),
         register_user_endpoint <- base_url <> @register_user_endpoint,
         request_fn <- fn -> HTTPoison.post(register_user_endpoint, body, headers, options) end,
         {:ok, json} <- ReqUtils.auto_retry(request_fn),
         %{"success" => true, "id" => user_id} <- json do
      {:ok, user_id}
    else
      {:retry_error, _} ->
        CircuitBreaker.add_service_error(@service_name)
        {:error, "could not receive from auth service"}

      {:error, %HTTPoison.Response{body: body}} ->
        {:error, Jason.decode!(body)}

      {:error, error_data} ->
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

  defp base_url(), do: ServicesAgent.get_service_address(@service_name)
end
