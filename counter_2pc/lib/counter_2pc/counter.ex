defmodule Counter2PC.Counter do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "counters" do
    field :count, :integer, default: 0
    field :user_id, :string
    field :count_2pc_next, :integer
    field :is_2pc_locked, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(counter, attrs) do
    counter
    |> cast(attrs, [:user_id, :count, :count_2pc_next, :is_2pc_locked])
    |> validate_required([:user_id, :count])
    |> unsafe_validate_unique(:user_id, Counter2PC.Repo)
    |> unique_constraint(:user_id)
  end
end
