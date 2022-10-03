defmodule Acai.Services.Generator do
  alias Acai.ServicesAgent

  @recv_timeout 1000
  @generate_avatar_endpoint "/api/avatar"

  def generate_avatar(socket, %{"size" => size, "name" => name, "type" => type}) do
    headers = get_headers(socket)
    options = get_options() ++ [params: [size: size, name: name, type: type]]

    dbg("sending request to generator: #{size} #{type} #{name}")

    with {:ok, base_url} <- base_url(),
         generate_avatar_url <- base_url <> @generate_avatar_endpoint,
         response <- HTTPoison.get(generate_avatar_url, headers, options),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response do
      dbg(body)
      {:ok, body}
    else
      error_data -> {:error, error_data}
    end
  end

  ## Privates

  defp base_url(), do: ServicesAgent.get_service_address("generator")

  defp get_headers(socket),
    do: [
      "durian-token": socket.assigns.user.token
    ]

  defp get_options(), do: [recv_timeout: @recv_timeout]
end
