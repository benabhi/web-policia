defmodule Policia.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :author, :string
    field :content, :string
    field :image_url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :content, :image_url, :author])
    |> validate_required([:title, :content, :image_url, :author])
  end
end
