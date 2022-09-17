import Config

config :acai, Acai.Repo,
  username: "postgres",
  password: "admin",
  port: 5433,
  hostname: "localhost",
  database: "acai_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10


config :acai, AcaiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "JsDa5C9DV9Ggz3Po1ppE4ttvcNr8Tfgyb4JpxdLg9D6MCX5PKAlryiUcEo9geaF9",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
