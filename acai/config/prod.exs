import Config

config :acai,
  service_discovery_base_url: "http://julik:8000"

config :acai, Acai.PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    host: "http://grafana:3000",
    # Or authenticate via Basic Auth
    username: "admin",
    password: "admin",
    upload_dashboards_on_start: true,
    folder_name: "Acai (gateway-prod) Dashboards",
    annotate_app_lifecycle: true
  ]

config :logger, level: :info
