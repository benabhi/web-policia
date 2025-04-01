defmodule Policia.ArticlesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Policia.Articles` context.
  """

  @doc """
  Generate a article.
  """
  def article_fixture(attrs \\ %{}) do
    {:ok, article} =
      attrs
      |> Enum.into(%{
        author: "some author",
        content: "some content",
        image_url: "some image_url",
        title: "some title"
      })
      |> Policia.Articles.create_article()

    article
  end
end
