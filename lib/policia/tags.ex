defmodule Policia.Tags do
  import Ecto.Query, warn: false
  alias Policia.Repo
  alias Policia.Tags.Tag

  # Esta es la función que obtendrá todos los tags de la base de datos
  def list_tags do
    Repo.all(Tag)
  end

  # Esta es una función opcional para obtener un solo tag por su ID
  def get_tag!(id), do: Repo.get!(Tag, id)

  # Puedes agregar más funciones relacionadas con Tag aquí si lo deseas
  # Crea un changeset para un Tag
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end
end
