defmodule PoliciaWeb.ArticleHTML do
  use PoliciaWeb, :html

  import Policia.Utils, only: [format_date: 1, format_time: 1]

  embed_templates "article_html/*"

  @doc """
  Renders a article form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :categories, :list, required: true

  def article_form(assigns)

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
        if String.trim(paragraph) != "" do
          "<p>#{paragraph |> String.trim() |> HtmlEntities.encode() |> add_line_breaks()}</p>"
        else
          ""
        end
      end)
      |> Enum.join("\n")
    end
  end

  def format_content(_), do: ""

  # Helper to convert single line breaks to <br>
  defp add_line_breaks(text) do
    text
    |> String.split("\n")
    |> Enum.join("<br>")
  end

  @doc """
  Obtiene el nombre de una categoría a partir de su ID y una lista de categorías.
  """
  def category_name(category_id, categories) do
    case Enum.find(categories, fn {_name, id} -> id == category_id end) do
      {name, _id} -> name
      _ -> "Categoría no encontrada"
    end
  end
end
