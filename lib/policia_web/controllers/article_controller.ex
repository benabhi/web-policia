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
    |> assign(:subtitle, "Mantente informado sobre las últimas novedades")
    |> render(:new, changeset: changeset, categories: categories)
  end

  def create(conn, %{"article" => article_params}) do
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
end
