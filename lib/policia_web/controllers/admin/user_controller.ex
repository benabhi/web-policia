defmodule PoliciaWeb.Admin.UserController do
  use PoliciaWeb, :controller

  alias Policia.Accounts
  alias Policia.Accounts.User

  @users_per_page 10

  def index(conn, params) do
    page = params_to_integer(params["page"], 1)

    %{entries: users, total_pages: total_pages} =
      Accounts.list_users_paginated(page, @users_per_page)

    conn
    |> assign(:page, page)
    |> assign(:total_pages, total_pages)
    |> render(:index, users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    # Asegurarse de que el rol sea válido
    user_params = Map.put_new(user_params, "role", "reader")

    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        conn
        |> PoliciaWeb.AlertHelper.put_alert(:success, "Usuario creado correctamente.")
        |> redirect(to: ~p"/admin/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Ecto.Changeset.change(user)
    render(conn, :edit, user: user, changeset: changeset, roles: User.roles())
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    # Prevenir que un administrador cambie su propio rol
    if user.id == conn.assigns.current_user.id && user_params["role"] != user.role do
      conn
      |> PoliciaWeb.AlertHelper.put_alert(
        :error,
        "No puedes cambiar tu propio rol de administrador."
      )
      |> redirect(to: ~p"/admin/users")
    else
      case Accounts.update_user_role(user, user_params["role"]) do
        {:ok, _user} ->
          conn
          |> PoliciaWeb.AlertHelper.put_alert(
            :success,
            "Rol de usuario actualizado correctamente."
          )
          |> redirect(to: ~p"/admin/users")

        {:error, _} ->
          conn
          |> PoliciaWeb.AlertHelper.put_alert(:error, "Error al actualizar el rol del usuario.")
          |> redirect(to: ~p"/admin/users")
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    # Prevenir que un administrador se elimine a sí mismo
    if user.id == conn.assigns.current_user.id do
      conn
      |> PoliciaWeb.AlertHelper.put_alert(
        :error,
        "No puedes eliminar tu propia cuenta de administrador."
      )
      |> redirect(to: ~p"/admin/users")
    else
      case Accounts.delete_user(user) do
        {:ok, _} ->
          conn
          |> PoliciaWeb.AlertHelper.put_alert(:success, "Usuario eliminado correctamente.")
          |> redirect(to: ~p"/admin/users")

        {:error, _} ->
          conn
          |> PoliciaWeb.AlertHelper.put_alert(:error, "Error al eliminar el usuario.")
          |> redirect(to: ~p"/admin/users")
      end
    end
  end

  # Función auxiliar para convertir parámetros de página a enteros
  defp params_to_integer(param, default) when is_binary(param) do
    case Integer.parse(param) do
      {num, _} -> num
      :error -> default
    end
  end

  defp params_to_integer(_, default), do: default
end
