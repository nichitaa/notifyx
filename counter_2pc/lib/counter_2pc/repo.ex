defmodule Counter2PC.Repo do
  use Ecto.Repo,
    otp_app: :counter_2pc,
    adapter: Ecto.Adapters.Postgres
end
