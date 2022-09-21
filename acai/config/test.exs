import Config

config :acai, AcaiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gd7D5y9LteC2/zueXIck55rGsYPP3w90R4b5+eln8HWR38TjC4ppmAuLPmBXkp6n",
  server: false

config :logger, level: :warn

config :phoenix, :plug_init_mode, :runtime
