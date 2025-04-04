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
    |> preload_results_with_category()
  end

  def get_article_with_category!(id) do
    Article
    |> Repo.get!(id)
    |> Repo.preload(:category)
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
  Searches articles by title or content.
  """
  def search_articles_paginated(search_term, page, per_page)
      when is_binary(search_term) and search_term != "" do
    search_pattern = "%#{search_term}%"

    Article
    |> where([a], ilike(a.title, ^search_pattern) or ilike(a.content, ^search_pattern))
    |> order_by([a], desc: a.inserted_at)
    |> Repo.paginate(page: page, page_size: per_page)
    |> preload_results_with_category()
  end

  # Función auxiliar para precargar categorías en resultados paginados
  defp preload_results_with_category(%{entries: entries} = paginated_results) do
    %{paginated_results | entries: Repo.preload(entries, :category)}
  end
end
