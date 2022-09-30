defmodule Acai.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Acai.ServicesAgent, %{}},
      AcaiWeb.Telemetry,
      {Phoenix.PubSub, name: Acai.PubSub},
      AcaiWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Acai.Supervisor]
    HTTPoison.start()
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AcaiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
