defmodule Kiwi.Persist.UserNotification do
  use Ecto.Schema
  import Ecto.Changeset
  use Accessible

  alias Kiwi.Persist.Notification

  @primary_key false
  @foreign_key_type :binary_id
  schema "users_notifications" do
    field :to_user_id, :binary_id
    field :status, Ecto.Enum, values: [:sent, :seen]

    belongs_to(:notification, Notification)

    timestamps()
  end

  @doc false
  def changeset(user_notification, attrs) do
    user_notification
    |> cast(attrs, [:to_user_id, :notification_id, :status])
    |> validate_required([:to_user_id, :notification_id, :status])
    |> unique_constraint([:notification_id, :to_user_id])
  end
end
