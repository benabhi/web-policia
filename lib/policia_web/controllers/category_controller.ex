defmodule PoliciaWeb.CategoryController do
  use PoliciaWeb, :controller

  alias Policia.Articles
  alias Policia.Articles.Category

  @categories_per_page 9

  def index(conn, params) do
    page = params_to_integer(params["page"], 1)

    # Obtener categorías paginadas
    %{entries: categories, total_pages: total_pages} =
      Articles.list_categories_paginated(page, @categories_per_page)

    conn
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
    |> render(:index, categories: categories)
  end

  # Función auxiliar para convertir parámetros de página a enteros
  defp params_to_integer(param, default) when is_binary(param) do
    case Integer.parse(param) do
      {num, _} -> num
      :error -> default
    end
  end

  defp params_to_integer(_, default), do: default

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
    old_slug = category.slug

    case Articles.update_category(category, category_params) do
      {:ok, category} ->
        # Mensaje personalizado si el slug cambió
        message =
          if old_slug != category.slug do
            "Categoría actualizada correctamente. El slug se ha actualizado de '#{old_slug}' a '#{category.slug}'."
          else
            "Categoría actualizada correctamente."
          end

        conn
        |> PoliciaWeb.AlertHelper.put_alert(:success, message)
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Articles.get_category!(id)

    # Verificar si hay artículos asociados a esta categoría
    articles_count = Policia.Repo.aggregate(Ecto.assoc(category, :articles), :count, :id)

    if articles_count > 0 do
      conn
      |> PoliciaWeb.AlertHelper.put_alert(
        :error,
        "No se puede eliminar la categoría porque tiene #{articles_count} artículos asociados."
      )
      |> redirect(to: ~p"/categories/#{category}")
    else
      {:ok, _category} = Articles.delete_category(category)

      conn
      |> PoliciaWeb.AlertHelper.put_alert(
        :success,
        "Categoría '#{category.name}' eliminada correctamente."
      )
      |> redirect(to: ~p"/categories")
    end
  end
end
