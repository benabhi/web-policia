defmodule Policia.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :author, :string
    field :content, :string
    field :image_url, :string
    field :image, :any, virtual: true

    belongs_to :category, Policia.Articles.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :content, :image_url, :author, :category_id, :image])
    |> validate_required([:title, :content, :author])
    |> validate_image()
  end

  # Valida la imagen si está presente
  defp validate_image(changeset) do
    case get_change(changeset, :image) do
      %Plug.Upload{} = upload ->
        validate_image_type(changeset, upload)

      nil ->
        # Si es un nuevo artículo, requiere imagen
        if !get_field(changeset, :id) && !get_field(changeset, :image_url) do
          add_error(changeset, :image, "debe subir una imagen para el artículo")
        else
          changeset
        end

      _ ->
        add_error(changeset, :image, "formato de archivo no válido")
    end
  end

  defp validate_image_type(changeset, upload) do
    # Verificar la extensión del archivo
    extension = upload.content_type |> validate_extension()

    if extension == :error do
      add_error(changeset, :image, "formato de imagen no válido, use: jpg, jpeg, png o gif")
    else
      # Verificar el tamaño (max 5MB)
      case File.stat(upload.path) do
        {:ok, %{size: size}} when size > 5_000_000 ->
          add_error(changeset, :image, "la imagen es demasiado grande (máximo 5MB)")

        {:ok, _} ->
          # Todo está bien con la imagen
          changeset

        {:error, _} ->
          add_error(changeset, :image, "error al procesar la imagen")
      end
    end
  end

  defp validate_extension(content_type) do
    case content_type do
      "image/jpeg" -> ".jpg"
      "image/jpg" -> ".jpg"
      "image/png" -> ".png"
      "image/gif" -> ".gif"
      _ -> :error
    end
  end
end
