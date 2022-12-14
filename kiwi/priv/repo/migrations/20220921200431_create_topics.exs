defmodule Kiwi.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :created_by, :binary_id, null: false
      add :longevity, :integer
      add :status, :string, null: false

      timestamps()
    end

    create unique_index(:topics, [:name])
  end
end
