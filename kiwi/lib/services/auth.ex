defmodule Kiwi.Services.Auth do
  alias Kiwi.Services.Discovery

  @recv_timeout 500
  @user_self_endpoint "/api/users/self"

  def get_user(conn) do
    headers_map = Enum.into(conn.req_headers, %{})
    options = [recv_timeout: @recv_timeout]

    headers = [
      {"content-type", headers_map["content_type"]},
      {"cookie", headers_map["cookie"]},
      {"host", headers_map["host"]}
    ]

    with {:ok, auth_base_url} <- Discovery.get_service_address("auth"),
         auth_self_url <- auth_base_url <> @user_self_endpoint,
         response <- HTTPoison.get(auth_self_url, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => %{"email" => email, "id" => id}} <- Jason.decode!(body) do
      user = %{email: email, id: id}
      {:ok, user}
    else
      _ -> {:error, nil}
    end
  end
end
