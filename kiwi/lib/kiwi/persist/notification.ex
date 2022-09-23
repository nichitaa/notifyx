defmodule Kiwi.Persist.Notification do
  use Ecto.Schema
  import Ecto.Changeset
  use Accessible

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :from, :integer
    field :message, :string
    field :seen_by, {:array, :binary_id}
    field :to, {:array, :binary_id}
    field :topic_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:message, :from, :seen_by, :to])
    |> validate_required([:message, :from, :seen_by, :to])
  end
end
