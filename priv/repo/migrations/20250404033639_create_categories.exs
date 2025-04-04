defmodule Policia.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :string

      timestamps(type: :utc_datetime)
    end

    # Indexar el slug para búsquedas más rápidas y asegurar unicidad
    create unique_index(:categories, [:slug])
  end
end
