defmodule Kiwi.Services.Discovery do
  def get_service_address(name) when is_binary(name) do
    url = base_url() <> "/api/service_address/#{name}"
    headers = ["Content-Type": "application/json"]
    options = [recv_timeout: 1500]

    response = HTTPoison.get(url, headers, options)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true, "address" => address} <- Jason.decode!(body) do
      {:ok, address}
    else
      _ -> {:error, :not_found}
    end
  end

  ## Privates

  defp base_url(), do: Application.fetch_env!(:kiwi, :service_discovery_base_url)
end
