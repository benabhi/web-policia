defmodule Policia.Config do
  @moduledoc """
  Módulo para obtener valores de configuración comunes de la aplicación.
  """

  @doc """
  Devuelve la configuración de la institución.
  """
  def institution do
    Application.get_env(:policia, :institution, [])
  end

  def webpage do
    Application.get_env(:policia, :webpage, [])
  end

  @doc """
  Devuelve el nombre completo de la institución.
  """
  def institution_name do
    institution()[:name] || "Institución"
  end

  @doc """
  Devuelve el nombre corto de la institución.
  """
  def institution_short_name do
    institution()[:short_name] || institution_name()
  end

  @doc """
  Devuelve el eslogan de la institución.
  """
  def institution_slogan do
    institution()[:slogan] || ""
  end

  def institution_emails do
    institution()[:emails] || []
  end

  def institution_social_links do
    institution()[:social_links] || []
  end

  def institution_phone do
    institution()[:phone] || ""
  end

  def institution_address do
    institution()[:address] || ""
  end

  def webpage_slider do
    webpage()[:slider] || true
  end

  # Puedes añadir más métodos para otros valores de configuración
end
