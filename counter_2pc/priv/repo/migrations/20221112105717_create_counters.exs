defmodule Counter2PC.Repo.Migrations.CreateCounters do
  use Ecto.Migration

  def change do
    create table(:counters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :string, null: false
      add :count, :integer, default: 0
      add :count_2pc_next, :integer
      add :is_2pc_locked, :boolean, null: false, default: false

      timestamps()
    end

    create unique_index(:counters, [:user_id])
  end
end
