defmodule Kiwi.Repo do
  use Ecto.Repo,
    otp_app: :kiwi,
    adapter: Ecto.Adapters.Postgres
end
