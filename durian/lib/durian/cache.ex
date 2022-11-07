defmodule Durian.Cache do
  use Nebulex.Cache,
    otp_app: :durian,
    # Replicate cache across all cluster nodes
    adapter: Nebulex.Adapters.Replicated,
    # Local adapter to store a cache replica
    primary_storage_adapter: Nebulex.Adapters.Local

  # To list all `Durian.Cache` module nodes: `Durian.Cache.nodes()`

  alias Durian.Repo
  alias Durian.Auth.User

  ## By :id

  def add_user(user) do
    put(user[:id], user, ttl: :timer.hours(1))
  end

  def get_user(id) do
    case get(id) do
      nil -> not_in_cache_response()
      user -> {:ok, user}
    end
  end

  ## By :token

  def add_user_with_token_as_key(user) do
    key = get_token_cache_key(user[:token])
    put(key, user, ttl: :timer.minutes(10))
  end

  def get_user_by_token(token) do
    key = get_token_cache_key(token)

    case get(key) do
      nil -> not_in_cache_response()
      user -> {:ok, user}
    end
  end

  def delete_user_by_token(token) do
    key = get_token_cache_key(token)
    delete(key)
  end

  ## List

  def add_users_list(users) do
    key = users_list_cache_key()
    put(key, users, ttl: :timer.minutes(2))
  end

  def get_users_list() do
    key = users_list_cache_key()

    case get(key) do
      nil -> not_in_cache_response()
      users -> {:ok, users}
    end
  end

  ## Utils

  def get_user_from_cache_or_db(token) do
    case get_user_by_token(token) do
      {:not_in_cache} ->
        with user when not is_nil(user) <- Repo.get_by(User, token: token) do
          add_user_with_token_as_key(user)
          {:ok, user}
        end

      cache_response ->
        cache_response
    end
  end

  ## Privates 

  defp not_in_cache_response(), do: {:not_in_cache}

  defp users_list_cache_key(), do: "users_list"

  defp get_token_cache_key(token) when is_binary(token), do: "token_" <> token
end
