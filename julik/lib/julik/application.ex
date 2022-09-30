defmodule Julik.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Julik.ServicesAgent, %{}},
      JulikWeb.Telemetry,
      {Phoenix.PubSub, name: Julik.PubSub},
      JulikWeb.Endpoint
    ]

    HTTPoison.start()
    opts = [strategy: :one_for_one, name: Julik.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    JulikWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
