defmodule Services.Utils do
  @doc """
  `service_name` and `address` must be strings (`binary`)
  """
  defmacro is_service_dto(service_name, address) do
    quote do: is_binary(unquote(service_name)) and is_binary(unquote(address))
  end
end
