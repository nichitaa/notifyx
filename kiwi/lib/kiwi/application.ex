defmodule Kiwi.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Kiwi.Cache,
      Kiwi.Repo,
      KiwiWeb.Telemetry,
      {Phoenix.PubSub, name: Kiwi.PubSub},
      KiwiWeb.Endpoint,
      {Kiwi.ServiceStarter, [timeout: 2000]}
    ]

    HTTPoison.start()
    opts = [strategy: :one_for_one, name: Kiwi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    KiwiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
