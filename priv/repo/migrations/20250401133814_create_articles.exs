defmodule Policia.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string
      add :content, :text
      add :image_url, :string
      add :author, :string

      timestamps(type: :utc_datetime)
    end
  end
end
