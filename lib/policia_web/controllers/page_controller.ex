defmodule PoliciaWeb.PageController do
  use PoliciaWeb, :controller
  import Policia.Utils, only: [format_date: 1]

  alias Policia.Articles
  alias Policia.Repo

  def home(conn, _params) do
    # Obtener los artículos más recientes para mostrar en la página principal
    latest_articles =
      Articles.list_articles_with_category()
      # Ahora puede usar Repo directamente
      |> Repo.preload(:user)
      |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
      |> Enum.take(6)
      |> Enum.map(fn article ->
        %{
          id: article.id,
          title: article.title,
          date: format_date(article.inserted_at),
          image: article.image_url || "/images/demo/featured1.png",
          excerpt: String.slice(article.content || "", 0, 150) <> "...",
          url: ~p"/articles/#{article}",
          category: if(article.category, do: article.category.name, else: nil),
          author:
            if(article.user,
              do: "#{article.user.first_name} #{article.user.last_name}",
              else: "Autor desconocido"
            )
        }
      end)

    render(conn, :home, latest_articles: latest_articles)
  end
end
