defmodule PoliciaWeb.PageController do
  use PoliciaWeb, :controller
  import Policia.Utils, only: [format_date: 1, format_time: 1]

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
          excerpt:
            if(String.length(article.content || "") > 150,
              do: String.slice(article.content || "", 0, 150) <> "...",
              else: article.content || ""
            ),
          url: ~p"/articles/#{article}",
          category: if(article.category, do: article.category.name, else: nil),
          author:
            if(article.user,
              do: "#{article.user.first_name} #{article.user.last_name}",
              else: "Autor desconocido"
            )
        }
      end)

    # Obtener el artículo destacado de la semana
    featured_article =
      Articles.get_featured_of_week()
      |> case do
        nil ->
          nil

        article ->
          %{
            id: article.id,
            title: article.title,
            date: format_date(article.inserted_at),
            time: format_time(article.inserted_at),
            image: article.image_url || "/images/demo/featured-weekly.png",
            content: article.content,
            url: ~p"/articles/#{article}",
            category: if(article.category, do: article.category.name, else: nil),
            category_url:
              if(article.category, do: ~p"/articles?category=#{article.category.slug}", else: nil),
            author:
              if(article.user,
                do: "#{article.user.first_name} #{article.user.last_name}",
                else: "Autor desconocido"
              )
          }
      end

    render(conn, :home, latest_articles: latest_articles, featured_article: featured_article)
  end
end
