defmodule Kiwi.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Kiwi.Repo,
      # Start the Telemetry supervisor
      KiwiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Kiwi.PubSub},
      # Start the Endpoint (http/https)
      KiwiWeb.Endpoint
      # Start a worker by calling: Kiwi.Worker.start_link(arg)
      # {Kiwi.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: Kiwi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    KiwiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
