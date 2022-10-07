defmodule Acai.Services.Discovery do
  @recv_timeout 2000

  def remove_service(name) do
    with remove_service_endpoint <- base_url() <> "/api/#{name}",
         response <- HTTPoison.delete(remove_service_endpoint, get_headers(), get_options()),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true} <- Jason.decode!(body) do
      :ok
    else
      _ ->
        :error
    end
  end

  ## Privates 

  defp get_options(), do: [recv_timeout: @recv_timeout]

  defp get_headers(),
    do: ["content-type": "application/json"]

  defp base_url(), do: Application.fetch_env!(:acai, :service_discovery_base_url)
end
