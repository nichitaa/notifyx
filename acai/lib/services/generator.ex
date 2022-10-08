defmodule Acai.Services.Generator do
  alias Acai.ServicesAgent
  alias Acai.Utils.ReqUtils
  alias Acai.CircuitBreaker

  @recv_timeout 1000
  @service_name "generator"
  @generate_avatar_endpoint "/api/avatar"

  def generate_avatar(socket, %{"size" => size, "name" => name, "type" => type}) do
    headers = get_headers(socket)
    options = get_options() ++ [params: [size: size, name: name, type: type]]

    dbg("sending request to generator: #{size} #{type} #{name}")

    with {:ok, base_url} <- base_url(),
         generate_avatar_url <- base_url <> @generate_avatar_endpoint,
         request_fn <- fn -> HTTPoison.get(generate_avatar_url, headers, options) end,
         {:ok, binary_png} <- ReqUtils.auto_retry(request_fn) do
      {:ok, binary_png}
    else
      {:retry_error, _} ->
        CircuitBreaker.add_service_error(@service_name)
        {:error, "Generator service error"}

      _ ->
        {:error, "Could not generate PNG avatar"}
    end
  end

  ## Privates

  defp base_url(), do: ServicesAgent.get_service_address("generator")

  defp get_headers(socket), do: ["durian-token": socket.assigns.user.token]

  defp get_options(), do: [recv_timeout: @recv_timeout]
end
