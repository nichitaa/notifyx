defmodule Kiwi.Services.Auth do
  def get_user(conn) do
    url = base_url() <> "/self"
    headers_map = Enum.into(conn.req_headers, %{})

    headers = [
      {"content-type", headers_map["content_type"]},
      {"cookie", headers_map["cookie"]},
      {"host", headers_map["host"]}
    ]

    options = [recv_timeout: 500]
    response = HTTPoison.get(url, headers, options)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "data" => %{"email" => email, "id" => id}} <- Jason.decode!(body) do
      user = %{email: email, id: id}
      {:ok, user}
    else
      _ -> {:error, nil}
    end
  end

  ## Privates

  defp base_url(), do: Application.fetch_env!(:kiwi, :auth_service_base_url)
end
