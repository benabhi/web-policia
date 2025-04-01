defmodule PoliciaWeb.TagController do
  use PoliciaWeb, :controller

  alias Policia.Tags
  alias Policia.Tags.Tag

  def index(conn, _params) do
    tags = Tags.list_tags()
    render(conn, "index.html", tags: tags)
  end

  def show(conn, %{"id" => id}) do
    tag = Tags.get_tag!(id)
    # Obtener artículos asociados al tag
    articles = Policia.Articles.list_articles_by_tag(id)
    render(conn, "show.html", tag: tag, articles: articles)
  end

  def new(conn, _params) do
    changeset = Tags.change_tag(%Tag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag" => tag_params}) do
    case Tags.create_tag(tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Tag created successfully.")
        |> redirect(to: ~p"/tags/#{tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
