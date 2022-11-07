import Config

config :guava,
  # In this service cluster, only one Node can expose endpoints, 
  # and act as parent not and load-balance requests, other Nodes could process
  # requests via RPC
  enable_rest_api: String.to_integer(System.get_env("ENABLE_REST_API") || "0"),
  service_discovery_base_url: "http://julik:8000",
  # test concurrent task limit with limit = 2, timeout = 5000
  concurent_task_limit: 10,
  # ms
  terminate_worker_after: 100,
  send_email_timeout: 1000

# Do not print debug messages in production
config :logger, level: :info

# Configure the Endpoint
config :guava, GuavaWeb.Endpoint,
  url: [host: "guava"],
  server: true
