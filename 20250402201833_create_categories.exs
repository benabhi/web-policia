defmodule Policia.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:slug])

    create table(:articles) do
      add :title, :string, null: false
      add :content, :string, null: false
      add :image_url, :string
      add :author, :string, null: false
      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:articles, [:category_id])
  end
end
