defmodule PoliciaWeb.ArticleController do
  use PoliciaWeb, :controller

  alias Policia.Articles
  alias Policia.Articles.Article

  def index(conn, _params) do
    articles = Articles.list_articles_with_category()

    conn
    |> assign(:page_title, "Articulos")
    |> assign(:subtitle, "Listado de artículos")
    |> render(:index, articles: articles)
  end

  def new(conn, _params) do
    changeset = Articles.change_article(%Article{})
    categories = get_category_options()

    conn
    |> assign(:page_title, "Crear un artículo")
    |> assign(:subtitle, "Creación de un nuevo artículo")
    |> render(:new, changeset: changeset, categories: categories)
  end

  def create(conn, %{"article" => article_params}) do
    # Procesamos la imagen si existe
    article_params = process_image(article_params)

    case Articles.create_article(article_params) do
      {:ok, article} ->
        conn
        |> put_flash(:info, "Artículo creado exitosamente.")
        |> redirect(to: ~p"/articles/#{article}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = get_category_options()
        render(conn, :new, changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    article = Articles.get_article_with_category!(id)
    render(conn, :show, article: article)
  end

  def edit(conn, %{"id" => id}) do
    article = Articles.get_article_with_category!(id)
    changeset = Articles.change_article(article)
    categories = get_category_options()
    render(conn, :edit, article: article, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "article" => article_params}) do
    article = Articles.get_article_with_category!(id)

    # Mantenemos la imagen existente si la casilla está marcada y no hay nueva imagen
    keep_existing = Map.get(conn.params, "keep_existing_image") == "true"
    article_params = process_image(article_params, article.image_url, keep_existing)

    case Articles.update_article(article, article_params) do
      {:ok, article} ->
        conn
        |> put_flash(:info, "Artículo actualizado exitosamente.")
        |> redirect(to: ~p"/articles/#{article}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = get_category_options()
        render(conn, :edit, article: article, changeset: changeset, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    article = Articles.get_article!(id)

    # Eliminar imagen si existe
    if article.image_url do
      delete_image(article.image_url)
    end

    {:ok, _article} = Articles.delete_article(article)

    conn
    |> put_flash(:info, "Artículo eliminado exitosamente.")
    |> redirect(to: ~p"/articles")
  end

  def all_articles(conn, _params) do
    articles = Articles.list_articles_with_category()
    categories = Articles.list_categories()

    conn
    |> assign(:page_title, "Todas las Noticias")
    |> assign(:subtitle, "Mantente informado sobre las últimas novedades")
    |> render(:all_articles, articles: articles, categories: categories)
  end

  def by_category(conn, %{"slug" => slug}) do
    category = Articles.get_category_by_slug!(slug)
    articles = Articles.list_articles_by_category(category.id)
    categories = Articles.list_categories()

    conn
    |> assign(:page_title, "Noticias: #{category.name}")
    |> assign(:subtitle, "Artículos en la categoría #{category.name}")
    |> render(:all_articles, articles: articles, categories: categories)
  end

  # Función auxiliar para obtener las opciones de categorías
  defp get_category_options do
    Articles.list_categories()
    |> Enum.map(fn c -> {c.name, c.id} end)
  end

  # Procesa la imagen y actualiza los parámetros del artículo
  defp process_image(article_params, existing_image_url \\ nil, keep_existing \\ false) do
    case article_params["image"] do
      %Plug.Upload{} = upload ->
        # Guardar imagen y actualizar parámetros
        case save_image(upload) do
          {:ok, image_path} ->
            # Si hay una imagen existente, la eliminamos para no dejar archivos huérfanos
            if existing_image_url, do: delete_image(existing_image_url)
            Map.put(article_params, "image_url", image_path)

          {:error, _reason} ->
            # Error al guardar la imagen, dejamos los parámetros sin cambios
            article_params
        end

      _ when keep_existing and is_binary(existing_image_url) ->
        # Mantener la imagen existente si la casilla está marcada
        Map.put(article_params, "image_url", existing_image_url)

      _ ->
        # No hay nueva imagen y no debemos mantener la existente
        article_params
    end
  end

  # Guarda la imagen con un nombre único
  defp save_image(upload) do
    # Crear directorio si no existe
    File.mkdir_p!("priv/static/images/articles")

    # Generar un nombre único para la imagen
    extension =
      case upload.content_type do
        "image/jpeg" -> ".jpg"
        "image/jpg" -> ".jpg"
        "image/png" -> ".png"
        "image/gif" -> ".gif"
        # Por defecto
        _ -> ".jpg"
      end

    # Generamos un nombre único con timestamp + uuid + extensión
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    unique_id = Ecto.UUID.generate() |> String.slice(0..7)
    filename = "#{timestamp}_#{unique_id}#{extension}"
    path = "priv/static/images/articles/#{filename}"

    # Guardar el archivo
    case File.cp(upload.path, path) do
      :ok ->
        # Retornar la ruta relativa para almacenar en la base de datos
        {:ok, "/images/articles/#{filename}"}

      {:error, reason} ->
        {:error, "Error al guardar imagen: #{reason}"}
    end
  end

  # Elimina una imagen del sistema de archivos
  defp delete_image(image_url) do
    # Extraer la ruta del archivo desde la URL
    if is_binary(image_url) && String.starts_with?(image_url, "/images/articles/") do
      filename = Path.basename(image_url)
      path = Path.join("priv/static/images/articles", filename)

      # Intentar eliminar el archivo
      case File.rm(path) do
        :ok -> :ok
        {:error, _reason} -> :error
      end
    end
  end
end
