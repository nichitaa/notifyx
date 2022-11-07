defmodule Durian.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies, [])

    children = [
      {Cluster.Supervisor, [topologies, [name: Durian.ClusterSupervisor]]},
      Durian.PromEx,
      {Durian.Cache, []},
      Durian.Repo,
      DurianWeb.Telemetry,
      {Phoenix.PubSub, name: Durian.PubSub},
      DurianWeb.Endpoint,
      {Durian.ServiceStarter, [timeout: 1000]}
    ]

    HTTPoison.start()
    opts = [strategy: :one_for_one, name: Durian.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    DurianWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
