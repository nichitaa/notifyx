defmodule Kiwi.Repo.Migrations.CreateUsersNotifications do
  use Ecto.Migration

  def change do
    create table(:users_notifications, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:to_user_id, :binary_id, null: false)
      # sent-seen
      add(:status, :string, null: false)

      timestamps()
    end
  end
end
