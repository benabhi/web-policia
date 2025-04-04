defmodule Policia.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string, null: false
      add :content, :text, null: false
      add :image_url, :string
      add :author, :string, null: false
      # Referencia a la tabla categories
      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    # Crear índice para la referencia a categorías
    create index(:articles, [:category_id])
    # Crear índice para búsquedas por título
    create index(:articles, [:title])
  end
end
