defmodule Durian.Repo do
  use Ecto.Repo,
    otp_app: :durian,
    adapter: Ecto.Adapters.Postgres
end
