defmodule Policia.Utils do
  @moduledoc """
  Módulo de utilidades generales para la aplicación Policia.
  """

  @doc """
  Formatea una fecha UTC en español.

  ## Ejemplos

      iex> format_date(~U[2025-04-02 00:00:00Z])
      "02 abril 2025"

  """
  def format_date(%DateTime{} = date) do
    day = Calendar.strftime(date, "%d")
    month = translate_month(Calendar.strftime(date, "%B"))
    year = Calendar.strftime(date, "%Y")
    "#{day} #{month} #{year}"
  end

  @doc """
  Traduce el nombre del mes de inglés a español.
  """
  def translate_month(month) do
    case String.downcase(month) do
      "january" -> "enero"
      "february" -> "febrero"
      "march" -> "marzo"
      "april" -> "abril"
      "may" -> "mayo"
      "june" -> "junio"
      "july" -> "julio"
      "august" -> "agosto"
      "september" -> "septiembre"
      "october" -> "octubre"
      "november" -> "noviembre"
      "december" -> "diciembre"
      _ -> month
    end
  end
end
