defmodule AcaiWeb.ServiceRegisterController do
  use AcaiWeb, :controller
  import Services.Utils

  alias Acai.ServicesAgent

  def register_service(conn, %{"service" => service, "address" => address})
      when is_service_dto(service, address) do
    case ServicesAgent.set_service_address(service, address) do
      :ok ->
        json(conn, %{success: true, message: "successfully registered #{service} service"})

      _ ->
        json(conn, %{success: true, message: "an error occurred at service registration"})
    end
  end
end
