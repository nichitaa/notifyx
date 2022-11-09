defmodule Kiwi.Persist.Notification do
  use Ecto.Schema
  import Ecto.Changeset
  use Accessible

  alias Kiwi.Persist.Topic
  alias Kiwi.Persist.UserNotification

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "notifications" do
    field :from_user_id, :binary_id
    field :message, :string
    field :is_2pc_locked, :boolean, default: false

    belongs_to(:topic, Topic)
    has_many(:users_notifications, UserNotification)

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:from_user_id, :message, :topic_id, :is_2pc_locked])
    |> validate_required([:from_user_id, :message, :topic_id])
  end
end
