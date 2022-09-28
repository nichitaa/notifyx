defmodule Kiwi.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:message, :string, null: false)
      add(:topic_id, references(:topics, type: :binary_id), null: false)
      add(:from_user_id, :binary_id, null: false)

      timestamps()
    end
  end
end
