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
  Formatea una hora en formato 24 horas.

  ## Ejemplos

      iex> format_time(~U[2025-04-02 15:30:00Z])
      "15:30"

  """
  def format_time(%DateTime{} = date) do
    Calendar.strftime(date, "%H:%M")
  end

  @doc """
  Formatea una fecha y hora en un formato legible.

  ## Ejemplos

      iex> format_datetime(~U[2025-04-02 15:30:00Z])
      "02 abril 2025 15:30"

  """
  def format_datetime(%DateTime{} = date) do
    "#{format_date(date)} #{format_time(date)}"
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
