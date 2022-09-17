defmodule Durian.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :expiry, :utc_datetime
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :hashed_password, :password, :token, :expiry])
    |> validate_required([:email, :hashed_password])
  end

  @doc false
  def register_user_changeset(user, attrs, opts \\ []) do
    dbg(user)
    dbg(attrs)

    user
    |> cast(attrs, [:email, :password])
    |> validate_email()
    |> validate_password(opts)
    |> dbg()
  end

  def valid_password?(%Durian.Auth.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Pbkdf2.verify_pass(password, hashed_password)
  end

  @doc """
  If there is no user or the user doesn't have a password, we call
  `Pbkdf2.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end

  ## Privates

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Durian.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 3, max: 10)
    |> hash_password(opts)
  end

  defp hash_password(changeset, _opts) do
    password = get_change(changeset, :password)

    if password do
      changeset
      |> put_change(:hashed_password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
