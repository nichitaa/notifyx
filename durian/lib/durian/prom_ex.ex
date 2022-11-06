defmodule Durian.PromEx do
  use PromEx, otp_app: :durian

  alias PromEx.Plugins

  @impl true
  def plugins do
    [
      Plugins.Application,
      Plugins.Beam,
      {Plugins.Phoenix, router: DurianWeb.Router, endpoint: DurianWeb.Endpoint},
      {Plugins.Ecto, otp_app: :durian, repos: [Durian.Repo]}
    ]
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: "prometheus"
    ]
  end

  @impl true
  def dashboards do
    [
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"},
      {:prom_ex, "phoenix.json"},
      {:prom_ex, "ecto.json"}
    ]
  end
end
