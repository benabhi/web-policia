defmodule PoliciaWeb.ArticleHTML do
  use PoliciaWeb, :html

  embed_templates "article_html/*"

  @doc """
  Renders a article form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :categories, :list, required: true

  def article_form(assigns)

  def format_date(%DateTime{} = date) do
    Policia.Utils.format_date(date)
  end

  def format_time(%DateTime{} = date) do
    Calendar.strftime(date, "%H:%M")
  end

  def format_content(content) when is_binary(content) do
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

  def format_content(_), do: ""

  # Helper to convert single line breaks to <br>
  defp add_line_breaks(text) do
    text
    |> String.split("\n")
    |> Enum.join("<br>")
  end
end
