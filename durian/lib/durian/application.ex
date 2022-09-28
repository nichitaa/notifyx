defmodule Durian.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Nebulex Cache
      Durian.Cache,
      # Start the Ecto repository
      Durian.Repo,
      # Start the Telemetry supervisor
      DurianWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Durian.PubSub},
      # Start the Endpoint (http/https)
      DurianWeb.Endpoint
      # Start a worker by calling: Durian.Worker.start_link(arg)
      # {Durian.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: Durian.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DurianWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
