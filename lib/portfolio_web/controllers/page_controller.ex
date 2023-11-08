defmodule PortfolioWeb.PageController do
  use PortfolioWeb, :controller

  def landing_page(conn, _params) do
    render(conn, :landing_page)
  end

  def license(conn, _params) do
    render(conn, :license)
  end

  def privacy(conn, _params) do
    render(conn, :privacy)
  end

  def articles(conn, %{"slug" => slug} = _params) do
    article_path = Path.join("priv/static/articles", "#{slug}.md")

    case File.read(article_path) do
      {:ok, markdown_content} ->
        render(
          conn,
          "article.html",
          markdown_content: markdown_content
        )

      {:error, _reason} ->
        conn
        |> put_status(:not_found)
        |> render("404.html")
    end
  end
end
