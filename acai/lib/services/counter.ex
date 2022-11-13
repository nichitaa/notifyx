defmodule Acai.Services.Counter do
  alias Acai.ServicesAgent
  @recv_timeout 1000

  # dynamic slug <> `/:user_id`
  @prepare_2pc_increment_endpoint "/api/prepare_increment_2pc"
  @commit_2pc_increment_endpoint "/api/commit_2pc"
  @rollback_2pc_increment_endpoint "/api/rollback_2pc"

  @doc """
  Used by `Acai.Services.Manager2PC`
  Returns {:ok, commit_function, rollback_function}
          {:error, error}
  """
  def init_2pc(socket) do
    response = prepare_2pc(socket)

    case response do
      {:ok, nil} ->
        commit_fn = fn -> commit_2pc(socket) end
        rollback_fn = fn -> rollback_2pc(socket) end
        {:ok, commit_fn, rollback_fn}

      error ->
        error
    end
  end

  def prepare_2pc(socket) do
    user_id = socket.assigns.user.user_id
    headers = get_headers(socket)
    options = get_options()

    with {:ok, base_url} <- base_url(),
         prepare_2pc_increment_url <-
           base_url <> @prepare_2pc_increment_endpoint <> "/#{user_id}",
         response <-
           HTTPoison.post(prepare_2pc_increment_url, Jason.encode!(%{}), headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true} <- Jason.decode!(body) do
      {:ok, nil}
    else
      error_data -> {:error, error_data}
    end
  end

  def commit_2pc(socket) do
    user_id = socket.assigns.user.user_id
    headers = get_headers(socket)
    options = get_options()

    with {:ok, base_url} <- base_url(),
         commit_2pc_increment_url <- base_url <> @commit_2pc_increment_endpoint <> "/#{user_id}",
         response <-
           HTTPoison.post(commit_2pc_increment_url, Jason.encode!(%{}), headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true} <- Jason.decode!(body) do
      {:ok, nil}
    else
      error_data -> {:error, error_data}
    end
  end

  def rollback_2pc(socket) do
    user_id = socket.assigns.user.user_id
    headers = get_headers(socket)
    options = get_options()

    with {:ok, base_url} <- base_url(),
         rollback_2pc_increment_url <-
           base_url <> @rollback_2pc_increment_endpoint <> "/#{user_id}",
         response <- HTTPoison.delete(rollback_2pc_increment_url, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true} <- Jason.decode!(body) do
      {:ok, nil}
    else
      error_data -> {:error, error_data}
    end
  end

  ## Privates

  defp base_url(), do: ServicesAgent.get_service_address("counter")

  defp get_headers(socket),
    do: [
      "content-type": "application/json",
      "durian-token": socket.assigns.user.token
    ]

  defp get_options(), do: [recv_timeout: @recv_timeout]
end
