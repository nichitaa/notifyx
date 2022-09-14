defmodule Durian.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Durian.Repo

  alias Durian.Auth.User

  def list_users do
    Repo.all(User)
  end

  def get_user(id), do: Repo.get(User, id)

  def register(attrs \\ %{}) do
    %User{}
    |> User.register_user_changeset(attrs)
    |> Repo.insert()
  end
end
