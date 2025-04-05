defmodule PoliciaWeb.ArticleController do
  use PoliciaWeb, :controller

  alias Policia.Articles
  alias Policia.Articles.Article
  import PoliciaWeb.UserAuth

  @articles_per_page 6

  plug :require_authenticated_user when action in [:new, :create, :edit, :update, :delete]

  def index(conn, params) do
    page = params_to_integer(params["page"], 1)
    search = Map.get(params, "search", "")
    category_slug = Map.get(params, "category", "")

    # Obtener artículos paginados con filtros aplicados
    {articles, total_pages} =
      cond do
        category_slug != "" ->
          # Si hay categoría seleccionada
          category = Articles.get_category_by_slug!(category_slug)

          %{entries: entries, total_pages: pages} =
            Articles.list_articles_by_category_paginated(category.id, page, @articles_per_page,
              search: search
            )

          {entries, pages}

        search != "" ->
          # Si hay búsqueda pero no categoría
          %{entries: entries, total_pages: pages} =
            Articles.search_articles_paginated(search, page, @articles_per_page)

          {entries, pages}

        true ->
          # Sin filtros
          %{entries: entries, total_pages: pages} =
            Articles.list_articles_with_category_paginated(page, @articles_per_page)

          {entries, pages}
      end

    # Obtener las 10 categorías más populares
    top_categories = Articles.list_top_categories(10)

    # Obtener todas las categorías (para otros usos, como el desplegable de filtros)
    all_categories = Articles.list_categories()

    conn
    |> assign(:page_title, "Noticias")
    |> assign(:subtitle, "Listado de todas las noticias del sitio")
    |> assign(:articles, articles)
    |> assign(:categories, all_categories)
    |> assign(:top_categories, top_categories)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
    |> assign(:search_term, search)
    |> assign(:current_category, category_slug)
    |> render(:index)
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
    # Asignar el ID del usuario actual al artículo
    article_params = Map.put(article_params, "user_id", conn.assigns.current_user.id)

    # Procesamos la imagen si existe
    article_params = process_image(article_params)

    case Articles.create_article(article_params) do
      {:ok, article} ->
        conn
        |> PoliciaWeb.AlertHelper.put_alert(:success, "Artículo creado exitosamente.")
        |> redirect(to: ~p"/articles/#{article}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = get_category_options()

        conn
        |> assign(:page_title, "Crear un artículo")
        |> assign(:subtitle, "Creación de un nuevo artículo")
        |> render(:new, changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    article = Articles.get_article_with_category!(id)
    categories = Articles.list_categories()

    # Obtener artículos relacionados (misma categoría)
    related_articles =
      if article.category_id do
        Articles.list_articles_by_category(article.category_id, 3, exclude_id: article.id)
      else
        []
      end

    conn
    |> assign(:article, article)
    |> assign(:categories, categories)
    |> assign(:related_articles, related_articles)
    |> assign(:page_title, article.title)
    |> render(:show)
  end

  def edit(conn, %{"id" => id}) do
    article = Articles.get_article_with_category!(id)
    changeset = Articles.change_article(article)
    categories = get_category_options()
    render(conn, :edit, article: article, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "article" => article_params}) do
    article = Articles.get_article_with_category!(id)

    # Verificar que el artículo pertenezca al usuario actual o tenga permisos
    unless article.user_id == conn.assigns.current_user.id do
      conn
      |> PoliciaWeb.AlertHelper.put_alert(:error, "No tienes permiso para editar este artículo.")
      |> redirect(to: ~p"/articles/#{article}")
      |> halt()
    end

    # Asegurar que el user_id no se cambie
    article_params = Map.put(article_params, "user_id", article.user_id)

    # Mantenemos la imagen existente si la casilla está marcada y no hay nueva imagen
    keep_existing = Map.get(conn.params, "keep_existing_image") == "true"
    article_params = process_image(article_params, article.image_url, keep_existing)

    case Articles.update_article(article, article_params) do
      {:ok, article} ->
        conn
        |> PoliciaWeb.AlertHelper.put_alert(:success, "Artículo actualizado exitosamente.")
        |> redirect(to: ~p"/articles/#{article}")

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = get_category_options()
        render(conn, :edit, article: article, changeset: changeset, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    article = Articles.get_article!(id)

    # Verificar que el artículo pertenezca al usuario actual o tenga permisos
    unless article.user_id == conn.assigns.current_user.id do
      conn
      |> PoliciaWeb.AlertHelper.put_alert(
        :error,
        "No tienes permiso para eliminar este artículo."
      )
      |> redirect(to: ~p"/articles/#{article}")
      |> halt()
    end

    # Eliminar imagen si existe
    if article.image_url do
      delete_image(article.image_url)
    end

    {:ok, _article} = Articles.delete_article(article)

    conn
    |> PoliciaWeb.AlertHelper.put_alert(:success, "Artículo eliminado exitosamente.")
    |> redirect(to: ~p"/articles")
  end

  def all_articles(conn, params) do
    page = params_to_integer(params["page"], 1)
    search = Map.get(params, "search", "")
    category_slug = Map.get(params, "category", "")

    # Filtrar por categoría si se proporciona un slug
    {articles, total_pages} =
      cond do
        category_slug != "" ->
          category = Articles.get_category_by_slug!(category_slug)

          %{entries: entries, total_pages: pages} =
            Articles.list_articles_by_category_paginated(category.id, page, @articles_per_page,
              search: search
            )

          {entries, pages}

        search != "" ->
          %{entries: entries, total_pages: pages} =
            Articles.search_articles_paginated(search, page, @articles_per_page)

          {entries, pages}

        true ->
          %{entries: entries, total_pages: pages} =
            Articles.list_articles_with_category_paginated(page, @articles_per_page)

          {entries, pages}
      end

    categories = Articles.list_categories()

    conn
    |> assign(:page_title, "Todas las Noticias")
    |> assign(:subtitle, "Mantente informado sobre las últimas novedades")
    |> assign(:articles, articles)
    |> assign(:categories, categories)
    |> assign(:current_category, category_slug)
    |> assign(:search_term, search)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
    |> render(:all_articles)
  end

  def by_category(conn, %{"slug" => slug} = params) do
    page = params_to_integer(params["page"], 1)
    search = Map.get(params, "search", "")

    category = Articles.get_category_by_slug!(slug)

    %{entries: articles, total_pages: total_pages} =
      Articles.list_articles_by_category_paginated(category.id, page, @articles_per_page,
        search: search
      )

    categories = Articles.list_categories()

    conn
    |> assign(:page_title, "Noticias: #{category.name}")
    |> assign(:subtitle, "Artículos en la categoría #{category.name}")
    |> assign(:articles, articles)
    |> assign(:categories, categories)
    |> assign(:current_category, slug)
    |> assign(:search_term, search)
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
    |> render(:all_articles)
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

  # Función auxiliar para convertir parámetros a enteros con valor por defecto
  defp params_to_integer(param, default) when is_binary(param) do
    case Integer.parse(param) do
      {value, _} when value > 0 -> value
      _ -> default
    end
  end

  defp params_to_integer(_, default), do: default
end
