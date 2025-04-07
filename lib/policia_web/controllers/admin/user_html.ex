defmodule PoliciaWeb.Admin.UserHTML do
  use PoliciaWeb, :html

  embed_templates "user_html/*"

  # Función para renderizar el formulario de usuario
  # Esta función se usa para incluir el template user_form.html.heex
  def user_form(assigns) do
    # El template user_form.html.heex se renderiza automáticamente
  end

  # Función para formatear la fecha
  def format_date(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end

  # Función para formatear el rol
  def format_role("reader"), do: "Lector"
  def format_role("writer"), do: "Escritor"
  def format_role("editor"), do: "Editor"
  def format_role("admin"), do: "Administrador"
  def format_role(role), do: String.capitalize(role)

  # Función para asignar color según el rol
  def role_color("reader"), do: "bg-gray-100 text-gray-800"
  def role_color("writer"), do: "bg-green-100 text-green-800"
  def role_color("editor"), do: "bg-blue-100 text-blue-800"
  def role_color("admin"), do: "bg-purple-100 text-purple-800"
  def role_color(_), do: "bg-gray-100 text-gray-800"
end
