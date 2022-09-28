defmodule Kiwi.Repo.Migrations.CreateUsersNotifications do
  use Ecto.Migration

  def change do
    create table(:users_notifications, primary_key: false) do
      add(:notification_id, references(:notifications, type: :binary_id), null: false)
      add(:to_user_id, :binary_id, null: false)
      # sent-seen
      add(:status, :string, null: false)

      timestamps()
    end

    create(unique_index(:users_notifications, [:notification_id, :to_user_id]))
  end
end
