defmodule Acai.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Acai.Repo,
      # Start the Telemetry supervisor
      AcaiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Acai.PubSub},
      # Start the Endpoint (http/https)
      AcaiWeb.Endpoint
      # Start a worker by calling: Acai.Worker.start_link(arg)
      # {Acai.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: Acai.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AcaiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
