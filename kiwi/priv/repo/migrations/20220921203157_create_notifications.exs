defmodule Kiwi.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :message, :string
      add :from, :integer
      add :seen_by, {:array, :integer}
      add :to, {:array, :integer}
      add :topic_id, references(:topics, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:notifications, [:topic_id])
  end
end