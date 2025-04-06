defmodule Policia.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string
      add :content, :text
      add :image_url, :string
      add :featured_of_week, :boolean, default: false

      # add :author, :string  <-- Comenta o elimina esta línea

      # Si prefieres mantenerlo por compatibilidad pero no usarlo:
      add :author, :string, null: true

      # Añadimos la referencia al usuario
      add :user_id, references(:users, on_delete: :nilify_all), null: true

      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:articles, [:category_id])
    # Añade un índice para user_id
    create index(:articles, [:user_id])
  end
end
