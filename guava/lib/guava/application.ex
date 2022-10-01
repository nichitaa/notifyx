defmodule Guava.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Guava.Balancer,
      Guava.WorkerDynamicSupervisor,
      # Google OAuth2.0
      {Goth, name: Guava.Goth},
      {Finch, name: Swoosh.Finch},
      # Cluster Supervisor (libcluster)
      {Cluster.Supervisor, [topologies(), [name: Guava.ClusterSupervisor]]},
      GuavaWeb.Telemetry,
      {Phoenix.PubSub, name: Guava.PubSub},
      GuavaWeb.Endpoint,
      {Guava.ServiceStarter, [timeout: 1000]}
    ]

    HTTPoison.start()
    opts = [strategy: :one_for_one, name: Guava.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    GuavaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # libcluster topologies
  defp topologies() do
    [
      background_job: [
        # Finds and connects to new nodes on its own
        strategy: Cluster.Strategy.Gossip
      ]
    ]
  end
end
