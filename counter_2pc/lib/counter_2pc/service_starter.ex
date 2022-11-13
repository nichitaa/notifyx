defmodule Counter2PC.ServiceStarter do
  use GenServer

  @default_timeout :timer.seconds(5)
  @register_endpoint "/api/register"
  @recv_timeout 1000

  def start_link(opts) do
    name = Keyword.get(opts, :name, __MODULE__)
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    GenServer.start_link(__MODULE__, timeout, name: name)
  end

  @impl true
  def init(timeout) do
    schedule(timeout)
    {:ok, timeout}
  end

  @impl true
  def handle_info(:register_self, timeout) do
    url = register_url!()
    headers = ["Content-Type": "application/json"]
    options = [recv_timeout: @recv_timeout]
    body = Jason.encode!(%{service: service_name(), address: address()})
    response = HTTPoison.post(url, body, headers, options)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         %{"success" => true} <- Jason.decode!(body) do
      dbg("successfully registered [counter]")
    else
      _ -> schedule(timeout)
    end

    {:noreply, timeout}
  end

  defp schedule(timeout), do: Process.send_after(self(), :register_self, timeout)
  defp address(), do: Counter2PCWeb.Endpoint.url()

  defp service_discovery_base_url!(),
    do: Application.fetch_env!(:counter_2pc, :service_discovery_base_url)

  defp register_url!(), do: service_discovery_base_url!() <> @register_endpoint
  defp service_name(), do: "counter"
end
