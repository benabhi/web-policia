defmodule PoliciaWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use PoliciaWeb, :html

  embed_templates "page_html/*"

  # Formatea el contenido del artículo para mostrar en la página
  def format_content(content) when is_binary(content) do
    # Si el contenido ya tiene etiquetas HTML (viene del editor rich text)
    if String.contains?(content, "<") && String.contains?(content, ">") do
      # Devolver el contenido tal cual, ya está formateado con HTML
      content
    else
      # Formato antiguo (texto plano) - convertir a HTML
      content
      |> String.split("\n\n")
      |> Enum.map(fn paragraph ->
        "<p>#{paragraph}</p>"
      end)
      |> Enum.join("\n")
    end
  end

  def format_content(_), do: ""
end
