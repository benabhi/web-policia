defmodule PoliciaWeb.CategoryController do
  use PoliciaWeb, :controller

  alias Policia.Articles
  alias Policia.Articles.Category

  def index(conn, _params) do
    categories = Articles.list_categories()
    render(conn, :index, categories: categories)
  end

  def new(conn, _params) do
    changeset = Articles.change_category(%Category{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"category" => category_params}) do
    case Articles.create_category(category_params) do
      {:ok, category} ->
        conn
        |> PoliciaWeb.AlertHelper.put_alert(:success, "Categoría creada exitosamente.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Articles.get_category!(id)
    render(conn, :show, category: category)
  end

  def edit(conn, %{"id" => id}) do
    category = Articles.get_category!(id)
    changeset = Articles.change_category(category)
    render(conn, :edit, category: category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Articles.get_category!(id)

    case Articles.update_category(category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Articles.get_category!(id)
    {:ok, _category} = Articles.delete_category(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: ~p"/categories")
  end
end
