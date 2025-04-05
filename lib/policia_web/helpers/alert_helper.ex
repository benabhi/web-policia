# lib/policia_web/helpers/alert_helper.ex
defmodule PoliciaWeb.AlertHelper do
  @moduledoc """
  Funciones auxiliares para manejar alertas y notificaciones en la aplicación.
  """

  import Plug.Conn, only: [assign: 3]

  @doc """
  Convierte mensajes flash y los asigna para ser usados por el componente alert_banner.
  Retorna un mapa con los datos necesarios para renderizar las alertas.
  """
  def prepare_alert(conn) do
    info = Phoenix.Flash.get(conn.assigns[:flash] || conn.flash, :info)
    error = Phoenix.Flash.get(conn.assigns[:flash] || conn.flash, :error)
    success = Phoenix.Flash.get(conn.assigns[:flash] || conn.flash, :success)

    cond do
      is_binary(success) && success != "" ->
        %{show: true, type: "success", message: success}

      is_binary(info) && info != "" ->
        # Aquí convierte info a success
        %{show: true, type: "success", message: info}

      is_binary(error) && error != "" ->
        %{show: true, type: "error", message: error}

      true ->
        %{show: false}
    end
  end

  @doc """
  Limpia las alertas de flash y las convierte al formato del componente alert_banner.
  """
  def put_alert(conn, type, message) when type in [:info, :success, :error, :warning] do
    # Convertir el tipo :info a :success para mantener consistencia con el componente alert_banner
    alert_type = if type == :info, do: "success", else: Atom.to_string(type)

    conn
    |> Phoenix.Controller.put_flash(type, message)
    |> assign(:alert, %{show: true, type: alert_type, message: message})
  end
end
