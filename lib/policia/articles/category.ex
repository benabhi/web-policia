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
    # Eliminamos :slug de los campos a procesar
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    # Generamos el slug automáticamente
    |> maybe_generate_slug()
    |> validate_required([:slug])
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "debe contener solo letras minúsculas, números y guiones"
    )
    |> unique_constraint(:slug)
  end

  defp maybe_generate_slug(changeset) do
    # Siempre generamos el slug a partir del nombre, ignorando cualquier valor de slug proporcionado
    case get_change(changeset, :name) do
      nil ->
        # Si no hay cambio en el nombre, mantenemos el slug existente
        changeset

      name ->
        # Generamos un slug limpio a partir del nombre
        slug =
          name
          # Convertir a minúsculas
          |> String.downcase()
          # Normalizar caracteres acentuados
          |> String.normalize(:nfd)
          # Eliminar marcas diacríticas (acentos)
          |> String.replace(~r/[\p{M}]/u, "")
          # Eliminar caracteres especiales
          |> String.replace(~r/[^a-z0-9\s-]/u, "")
          # Eliminar espacios al inicio y final
          |> String.trim()
          # Reemplazar espacios con guiones
          |> String.replace(~r/\s+/, "-")
          # Evitar guiones múltiples consecutivos
          |> String.replace(~r/-+/, "-")

        # Aseguramos que el slug no esté vacío
        slug = if String.length(slug) == 0, do: "categoria", else: slug

        # Añadimos el slug al changeset
        put_change(changeset, :slug, slug)
    end
  end
end
