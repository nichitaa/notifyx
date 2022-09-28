defmodule Kiwi.Repo.Migrations.CreateTopicSubscribers do
  use Ecto.Migration

  def change do
    create table(:topic_subscribers, primary_key: false) do
      add(:topic_id, references(:topics, type: :binary_id), null: false)
      add(:user_id, :binary_id, null: false)

      timestamps()
    end

    create(unique_index(:topic_subscribers, [:topic_id, :user_id]))
  end
end
