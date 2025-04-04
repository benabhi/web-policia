# lib/policia_web/controllers/user_session_controller.ex
defmodule PoliciaWeb.UserSessionController do
  use PoliciaWeb, :controller

  alias Policia.Accounts
  alias PoliciaWeb.UserAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"username" => username, "password" => password} = user_params

    if user = Accounts.get_user_by_username_and_password(username, password) do
      conn
      |> put_flash(:info, "Bienvenido de nuevo!")
      |> UserAuth.log_in_user(user, user_params)
    else
      # Para prevenir enumeración de usuarios, no revelar si el username existe
      render(conn, :new, error_message: "Usuario o contraseña inválidos")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Sesión cerrada exitosamente.")
    |> UserAuth.log_out_user()
  end
end
