defmodule Acai.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AcaiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Acai.PubSub},
      # Start the Endpoint (http/https)
      AcaiWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Acai.Supervisor]
    HTTPoison.start()
    dbg("Starting Acai.Application...")
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AcaiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
