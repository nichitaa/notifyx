defmodule Kiwi.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :created_by, :binary_id
      add :longevity, :integer
      add :status, :string

      timestamps()
    end

    create unique_index(:topics, [:name])
  end
end
