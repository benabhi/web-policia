defmodule PoliciaWeb.Router do
  use PoliciaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PoliciaWeb.Layouts, :root}
    plug :put_layout, html: {PoliciaWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # No necesitamos agregar Plug.Parsers aquí porque ya está definido en endpoint.ex
  # Phoenix configura esto automáticamente

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PoliciaWeb do
    pipe_through :browser

    get "/", PageController, :home

    # Coloca la ruta personalizada ANTES del recurso
    get "/articles/all", ArticleController, :all_articles
    get "/articles/category/:slug", ArticleController, :by_category
    resources "/articles", ArticleController
    resources "/categories", CategoryController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PoliciaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:policia, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PoliciaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
