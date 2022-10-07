defmodule Acai.ServicesAgent do
  use Agent
  import Services.Utils
  alias Acai.Services

  def start_link(init_opts),
    do: Agent.start_link(fn -> init_opts end, name: __MODULE__)

  def set_service_address(name, address) when is_service_dto(name, address),
    do: Agent.update(__MODULE__, &Map.put(&1, name, address))

  def get_service_address(name) when is_binary(name),
    do: Agent.get(__MODULE__, &Map.fetch(&1, name))

  def remove_service(name) when is_binary(name) do
    Agent.update(__MODULE__, &Map.delete(&1, name))
    # sync with discovery service
    :ok = Services.Discovery.remove_service(name)
  end

  def get_all(), do: Agent.get(__MODULE__, & &1)
end
