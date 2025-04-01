defmodule Policia.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :author, :string
    field :content, :string
    field :image_url, :string
    many_to_many :tags, Policia.Tags.Tag, join_through: "articles_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :content, :image_url, :author])
    |> validate_required([:title, :content, :image_url, :author])
    |> cast_assoc(:tags, with: &Policia.Tags.Tag.changeset/2)
  end
end
