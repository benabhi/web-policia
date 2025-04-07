defmodule Policia.Articles do
  @moduledoc """
  The Articles context.
  """

  import Ecto.Query, warn: false
  alias Policia.Repo

  alias Policia.Articles.Article
  alias Policia.Articles.Category

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Repo.all(Article)
  end

  @doc """
  Returns a paginated list of articles.
  """
  def list_articles_paginated(page, per_page) do
    Article
    |> order_by([a], desc: a.inserted_at)
    |> Repo.paginate(page: page, page_size: per_page)
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id)

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    # Verificar si se está marcando como destacado de la semana
    if Map.get(attrs, "featured_of_week") == "true" || Map.get(attrs, :featured_of_week) == true do
      # Desmarcar cualquier otro artículo que esté marcado como destacado
      from(a in Article, where: a.featured_of_week == true)
      |> Repo.update_all(set: [featured_of_week: false])
    end

    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    # Verificar si se está marcando como destacado de la semana
    if Map.get(attrs, "featured_of_week") == "true" || Map.get(attrs, :featured_of_week) == true do
      # Desmarcar cualquier otro artículo que esté marcado como destacado
      from(a in Article, where: a.featured_of_week == true and a.id != ^article.id)
      |> Repo.update_all(set: [featured_of_week: false])
    end

    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  def list_categories do
    Repo.all(Category)
    |> Repo.preload(:articles)
  end

  @doc """
  Returns a paginated list of categories.
  """
  def list_categories_paginated(page, per_page) do
    Category
    |> order_by([c], asc: c.name)
    |> Repo.paginate(page: page, page_size: per_page)
    |> preload_results_with_articles()
  end

  # Función auxiliar para precargar artículos en resultados paginados
  defp preload_results_with_articles(%{entries: entries} = paginated_results) do
    %{paginated_results | entries: Repo.preload(entries, :articles)}
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def get_category_by_slug!(slug), do: Repo.get_by!(Category, slug: slug)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  def list_articles_with_category do
    Article
    |> order_by([a], desc: a.inserted_at)
    |> Repo.all()
    |> Repo.preload(:category)
  end

  @doc """
  Returns a paginated list of articles with their categories.
  """
  def list_articles_with_category_paginated(page, per_page) do
    Article
    |> order_by([a], desc: a.inserted_at)
    |> Repo.paginate(page: page, page_size: per_page)
    |> preload_results_with_category_and_user()
  end

  def get_article_with_category!(id) when id == "new" do
    # Caso especial para evitar el error cuando id es "new"
    raise Ecto.NoResultsError, queryable: Article
  end

  def get_article_with_category!(id) do
    Article
    |> Repo.get!(id)
    |> Repo.preload([:category, :user])
  end

  def list_articles_by_category(category_id, limit \\ nil, opts \\ []) do
    exclude_id = Keyword.get(opts, :exclude_id)

    query =
      from a in Article,
        where: a.category_id == ^category_id,
        order_by: [desc: a.inserted_at]

    query =
      if exclude_id do
        from a in query, where: a.id != ^exclude_id
      else
        query
      end

    query =
      if limit do
        from a in query, limit: ^limit
      else
        query
      end

    query
    |> Repo.all()
    |> Repo.preload(:category)
  end

  @doc """
  Returns a paginated list of articles for a specific category.
  """
  def list_articles_by_category_paginated(category_id, page, per_page, opts \\ []) do
    search = Keyword.get(opts, :search, "")

    base_query =
      from a in Article,
        where: a.category_id == ^category_id,
        order_by: [desc: a.inserted_at]

    # Añadir búsqueda si se proporciona un término
    query =
      if search && search != "" do
        search_term = "%#{search}%"

        from a in base_query,
          where: ilike(a.title, ^search_term) or ilike(a.content, ^search_term)
      else
        base_query
      end

    query
    |> Repo.paginate(page: page, page_size: per_page)
    |> preload_results_with_category()
  end

  @doc """
  Returns the article marked as featured of the week.
  If multiple articles are marked, returns the most recent one.
  """
  def get_featured_of_week do
    Article
    |> where([a], a.featured_of_week == true)
    |> order_by([a], desc: a.inserted_at)
    |> limit(1)
    |> Repo.one()
    |> Repo.preload([:category, :user])
  end

  @doc """
  Searches articles by title or content.
  """
  def search_articles_paginated(search_term, page, per_page)
      when is_binary(search_term) and search_term != "" do
    # Para hacer la búsqueda insensible a mayúsculas/minúsculas en SQLite
    search_pattern = "%#{String.downcase(search_term)}%"

    Article
    |> where(
      [a],
      like(fragment("lower(?)", a.title), ^search_pattern) or
        like(fragment("lower(?)", a.content), ^search_pattern)
    )
    |> order_by([a], desc: a.inserted_at)
    |> Repo.paginate(page: page, page_size: per_page)
    |> preload_results_with_category()
  end

  @doc """
  Retorna las 10 categorías con más artículos.
  """
  def list_top_categories(limit \\ 10) do
    Repo.all(
      from c in Category,
        left_join: a in assoc(c, :articles),
        group_by: c.id,
        order_by: [desc: count(a.id)],
        select: {c, count(a.id)},
        limit: ^limit
    )
    |> Enum.map(fn {category, count} ->
      # Estructura con el count para mostrar en la UI
      Map.put(category, :article_count, count)
    end)
  end

  # Función auxiliar para precargar categorías en resultados paginados
  defp preload_results_with_category_and_user(%{entries: entries} = paginated_results) do
    %{paginated_results | entries: Repo.preload(entries, [:category, :user])}
  end

  defp preload_results_with_category(%{entries: entries} = paginated_results) do
    %{paginated_results | entries: Repo.preload(entries, :category)}
  end
end
