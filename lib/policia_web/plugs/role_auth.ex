defmodule PoliciaWeb.Plugs.RoleAuth do
  @moduledoc """
  Plug para verificar que un usuario tiene el rol requerido.
  """
  import Plug.Conn
  import Phoenix.Controller
  use PoliciaWeb, :verified_routes

  @doc """
  Verifica que el usuario actual tiene al menos el rol mínimo especificado.
  """
  def init(min_role), do: min_role

  def call(conn, min_role) do
    alias Policia.Accounts.User

    user = conn.assigns.current_user

    if user && User.has_role_or_higher?(user, min_role) do
      conn
    else
      conn
      |> PoliciaWeb.AlertHelper.put_alert(
        :error,
        "No tienes permisos suficientes para acceder a esta página."
      )
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
