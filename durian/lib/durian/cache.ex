defmodule Durian.Cache do
  use Nebulex.Cache,
    otp_app: :durian,
    adapter: Nebulex.Adapters.Local

  def add_user(user) do
    put(user[:id], user, ttl: :timer.hours(1))
  end

  def get_user(id) do
    case get(id) do
      nil -> not_in_cache_response()
      user -> {:ok, user}
    end
  end

  def add_users_list(users) do
    key = users_list_cache_key()
    put(key, users, ttl: :timer.seconds(5))
  end

  def get_users_list() do
    key = users_list_cache_key()

    case get(key) do
      nil -> not_in_cache_response()
      users -> {:ok, users}
    end
  end

  ## Privates 

  defp not_in_cache_response() do
    {:not_in_cache}
  end

  defp users_list_cache_key() do
    "users_list"
  end
end
