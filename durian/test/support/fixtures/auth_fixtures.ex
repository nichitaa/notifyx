defmodule Durian.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Durian.Auth` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        expiry: ~U[2022-09-13 07:11:00Z],
        hashed_password: "some hashed_password",
        token: "some token"
      })
      |> Durian.Auth.create_user()

    user
  end
end
