defmodule Policia.Articles.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :slug, :string
    # Cambiado de :text a :string
    field :description, :string

    # Simplemente declara la relación sin importar el módulo Article
    has_many :articles, Policia.Articles.Article

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug, :description])
    |> validate_required([:name])
    |> maybe_generate_slug()
    |> validate_required([:slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "debe contener solo letras minúsculas, números y guiones"
    )
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        case get_change(changeset, :name) do
          nil ->
            changeset

          name ->
            slug =
              name
              |> String.downcase()
              |> String.replace(~r/[^a-z0-9\s-]/, "")
              |> String.replace(~r/\s+/, "-")

            put_change(changeset, :slug, slug)
        end

      _ ->
        changeset
    end
  end
end
