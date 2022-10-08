defmodule Acai.CircuitBreaker do
  alias Acai.ServicesAgent
  use GenServer

  # in seconds
  @default_reset_timeout 10
  @default_service_threshold 2

  def start_link(init_args \\ []) do
    config = get_config()
    arg_timeout = Keyword.get(init_args, :reset_timeout, @default_reset_timeout)
    reset_timeout = Keyword.get(config, :reset_timeout, arg_timeout)
    initial_state = {to_seconds(reset_timeout), %{}}
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  ## Client API

  def add_service_error(service_name),
    do: GenServer.cast(__MODULE__, {:service_error, service_name})

  ## Callbacks

  def init(state) do
    {timeout, _map} = state
    schedule(timeout)
    {:ok, state}
  end

  def handle_cast({:service_error, service_name}, state) do
    {timeout, services_error_counter} = state
    service_error_threshold = get_service_threshold(service_name)
    current_error_count = Map.get(services_error_counter, service_name, 0)

    updated_services_error_counter =
      if current_error_count >= service_error_threshold do
        # remove service
        ServicesAgent.remove_service(service_name)
        Map.delete(services_error_counter, service_name)
      else
        Map.update(services_error_counter, service_name, 1, fn counter -> counter + 1 end)
      end

    {:noreply, {timeout, updated_services_error_counter}}
  end

  def handle_info(:reset, {timeout, _services_error_counter}) do
    schedule(timeout)
    {:noreply, {timeout, %{}}}
  end

  ## Privates

  defp get_service_threshold(service_name) when is_binary(service_name) do
    config = get_config()
    service_name_atom = String.to_atom(service_name)
    service_threshold = Keyword.get(config, service_name_atom, @default_service_threshold)
    service_threshold
  end

  defp schedule(timeout), do: Process.send_after(self(), :reset, timeout)

  defp to_seconds(number), do: :timer.seconds(number)

  defp get_config(), do: Application.fetch_env!(:acai, Acai.CircuitBreaker)
end
