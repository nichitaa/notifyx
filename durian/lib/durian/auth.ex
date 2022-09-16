defmodule Durian.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Durian.Repo

  alias Durian.Auth.User

  @hash_algorithm :sha256
  @rand_size 32

  def list_users do
    Repo.all(User)
  end

  def get_user(id), do: Repo.get(User, id)

  def register(attrs \\ %{}) do
    %User{}
    |> User.register_user_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  def update_user_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    token = Base.url_encode64(token)

    # TODO: add validation & expiry

    user
    |> User.changeset(%{token: token})
    |> Repo.update()
  end
end
