defmodule PoliciaWeb.PageController do
  use PoliciaWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    IO.inspect(conn.assigns.current_user)
    render(conn, :home)
  end
end
