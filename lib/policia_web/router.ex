defmodule PoliciaWeb.Router do
  use PoliciaWeb, :router

  import PoliciaWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PoliciaWeb.Layouts, :root}
    plug :put_layout, html: {PoliciaWeb.Layouts, :app}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # No necesitamos agregar Plug.Parsers aquí porque ya está definido en endpoint.ex
  # Phoenix configura esto automáticamente

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Pipelines para roles
  pipeline :require_writer do
    plug PoliciaWeb.Plugs.RoleAuth, "writer"
  end

  pipeline :require_editor do
    plug PoliciaWeb.Plugs.RoleAuth, "editor"
  end

  pipeline :require_admin do
    plug PoliciaWeb.Plugs.RoleAuth, "admin"
  end

  # Ruta especial para crear nuevos artículos (debe estar antes de /articles/:id)
  scope "/", PoliciaWeb do
    pipe_through [:browser, :require_authenticated_user, :require_writer]

    get "/articles/new", ArticleController, :new
  end

  scope "/", PoliciaWeb do
    pipe_through :browser

    get "/", PageController, :home

    get "/articles", ArticleController, :index
    get "/articles/category/:slug", ArticleController, :by_category
    get "/articles/:id", ArticleController, :show

    # Rutas públicas (no requieren autenticación)
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

  ## Authentication routes

  scope "/", PoliciaWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  # Rutas para usuarios autenticados (cualquier rol)
  scope "/", PoliciaWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  # Rutas para escritores y roles superiores
  scope "/", PoliciaWeb do
    pipe_through [:browser, :require_authenticated_user, :require_writer]

    # La ruta get "/articles/new" se movió al scope público
    # pero necesita protección de autenticación y rol
    post "/articles", ArticleController, :create
  end

  # Rutas para editores y roles superiores
  scope "/", PoliciaWeb do
    pipe_through [:browser, :require_authenticated_user, :require_editor]

    get "/articles/:id/edit", ArticleController, :edit
    put "/articles/:id", ArticleController, :update
    patch "/articles/:id", ArticleController, :update
    put "/articles/:id/toggle_featured", ArticleController, :toggle_featured

    # Rutas de categorías para editores
    resources "/categories", CategoryController
  end

  # Rutas para administradores
  scope "/", PoliciaWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    delete "/articles/:id", ArticleController, :delete
  end

  # Rutas para administración de usuarios (solo admin)
  scope "/admin", PoliciaWeb.Admin do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    resources "/users", UserController, except: [:show]
  end

  scope "/", PoliciaWeb do
    pipe_through [:browser]

    post "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
