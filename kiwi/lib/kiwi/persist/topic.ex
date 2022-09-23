defmodule Kiwi.Persist.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  use Accessible

  alias Kiwi.Persist.Notification

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "topics" do
    field :created_by, :binary_id
    field :longevity, :integer
    field :name, :string
    field :status, Ecto.Enum, values: [:active, :inactive]

    has_many(:notifications, Notification)

    timestamps()
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:name, :created_by, :longevity, :status])
    |> validate_required([:name, :created_by, :longevity, :status])
    |> unique_constraint(:name)
  end
end
