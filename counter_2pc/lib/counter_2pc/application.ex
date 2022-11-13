defmodule Counter2PC.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Counter2PC.Repo,
      # Start the Telemetry supervisor
      Counter2PCWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Counter2PC.PubSub},
      # Start the Endpoint (http/https)
      Counter2PCWeb.Endpoint,
      Counter2PC.ServiceStarter
      # Start a worker by calling: Counter2PC.Worker.start_link(arg)
      # {Counter2PC.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Counter2PC.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Counter2PCWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
