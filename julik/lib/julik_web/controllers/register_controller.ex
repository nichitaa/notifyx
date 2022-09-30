defmodule JulikWeb.RegisterController do
  use JulikWeb, :controller
  alias Julik.ServicesAgent

  def register(conn, %{"service" => service, "address" => address})
      when is_binary(service) and is_binary(address) do
    url = gateway_register_service_url!()
    headers = ["Content-Type": "application/json"]
    options = [recv_timeout: 1500]
    body = Jason.encode!(%{service: service, address: address})
    response = HTTPoison.post(url, body, headers, options)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true} <- Jason.decode!(body) do
      ServicesAgent.set_service_address(service, address)
      json(conn, %{success: true})
    else
      _ -> json(conn, %{success: false})
    end
  end

  def get_service_address(conn, %{"service_name" => service_name}) do
    case ServicesAgent.get_service_address(service_name) do
      :error -> json(conn, %{success: false, message: "service was not register yet"})
      {:ok, address} -> json(conn, %{success: true, address: address})
    end
  end

  ## Privates

  defp gateway_register_service_url!(),
    do: Application.fetch_env!(:julik, :gateway_base_url) <> "/api/register_service"
end
