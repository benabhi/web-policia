defmodule PoliciaWeb.CustomComponents do
  use Phoenix.Component
  alias Policia.Config
  # alias Policia.Utils
  import PoliciaWeb.CoreComponents

  # Componente para mensajes de "no hay elementos"
  attr :message, :string, required: true, doc: "Mensaje principal a mostrar"
  attr :description, :string, required: true, doc: "Descripción o texto secundario"
  attr :icon, :string, default: "hero-information-circle", doc: "Nombre del icono a mostrar"
  attr :color_theme, :string, default: nil, doc: "Tema de color (blue, green, etc.)"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"
  attr :action_text, :string, default: nil, doc: "Texto opcional para el botón de acción"
  attr :action_url, :string, default: nil, doc: "URL opcional para el botón de acción"
  attr :action_icon, :string, default: nil, doc: "Icono opcional para el botón de acción"

  def empty_state(assigns) do
    assigns = assign_new(assigns, :color_theme, fn -> Config.webpage_theme() end)

    ~H"""
    <div class={[
      "bg-#{@color_theme}-50 border border-#{@color_theme}-200 text-#{@color_theme}-800 rounded-md p-6 text-center",
      @class
    ]}>
      <.icon name={@icon} class={"mx-auto h-12 w-12 text-#{@color_theme}-400 mb-4"} />
      <h3 class="text-lg font-semibold mb-2">{@message}</h3>
      <p class={"text-#{@color_theme}-700 mb-4"}>
        {@description}
      </p>
      <%= if @action_text && @action_url do %>
        <.link href={@action_url}>
          <.app_button icon={@action_icon} size="md">
            {@action_text}
          </.app_button>
        </.link>
      <% end %>
    </div>
    """
  end

  # Componente para menu superior y lateral dinamico
  attr :menus, :list,
    default: [],
    doc: "Lista de menús principales con enlaces y submenús opcionales."

  attr :current_path, :string,
    default: nil,
    doc: "Ruta actual para resaltar el ítem de menú activo"

  attr :logo_src, :string,
    default: nil,
    doc: "Ruta opcional para el logo del sitio"

  attr :site_name, :string,
    default: "Gobierno de Río Negro",
    doc: "Nombre del sitio para mostrar junto al logo"

  attr :current_user, :any, default: nil, doc: "Usuario actualmente autenticado"

  def nav_menu(assigns) do
    # Usa el valor de configuración si no se proporciona site_name
    assigns =
      assigns
      |> assign_new(:site_name, fn -> Config.institution_name() end)
      |> assign_new(:menu_id, fn ->
        "main-menu-" <> Integer.to_string(Enum.random(1000..9999))
      end)
      |> assign_new(:color_theme, fn -> Config.webpage_theme() end)
      |> assign_new(:current_user, fn -> assigns[:current_user] end)

    # Nota: Para que este componente funcione correctamente,
    # asegúrate de que tu archivo CSS global (app.css) incluya:
    # [x-cloak] { display: none !important; }

    ~H"""
    <div class={"bg-#{@color_theme}-950 w-full"}>
      <!-- Alpine.js maneja el comportamiento del menú sin scripts ni estilos adicionales -->
             <!-- Versión móvil con menú lateral deslizante usando Alpine.js -->
      <div
        class="md:hidden"
        x-data="{ menuOpen: false }"
        @keydown.escape="menuOpen = false; document.body.classList.remove('overflow-hidden')"
      >
        <!-- Overlay para cerrar el menú lateral cuando se hace click fuera -->
        <div
          x-show="menuOpen"
          x-transition:enter="transition-opacity ease-out duration-300"
          x-transition:enter-start="opacity-0"
          x-transition:enter-end="opacity-100"
          x-transition:leave="transition-opacity ease-in duration-300"
          x-transition:leave-start="opacity-100"
          x-transition:leave-end="opacity-0"
          @click="menuOpen = false; document.body.classList.remove('overflow-hidden')"
          class="fixed inset-0 bg-black bg-opacity-50 z-30"
          x-cloak
          aria-hidden="true"
        >
        </div>
        
    <!-- Header móvil con logo o nombre del sitio y botón hamburguesa -->
        <div class="container mx-auto px-4 py-3 flex items-center justify-between relative z-10">
          <!-- Logo o nombre del sitio -->
          <div class="flex items-center">
            <a href="/" class="flex items-center text-white">
              <%= if @logo_src do %>
                <img src={@logo_src} alt={@site_name} class="h-8 w-auto mr-2" />
              <% end %>
              <span class="text-white font-semibold text-lg">
                {@site_name}
              </span>
            </a>
          </div>
          
    <!-- Botón hamburguesa -->
          <button
            type="button"
            aria-expanded="false"
            x-bind:aria-expanded="menuOpen.toString()"
            aria-controls={@menu_id}
            @click="menuOpen = true; document.body.classList.add('overflow-hidden')"
            id="mobile-menu-button"
            class={"text-white hover:text-#{@color_theme}-200 focus:outline-none focus:ring-2 focus:ring-#{@color_theme}-300 p-2 rounded-md transition-colors duration-200"}
          >
            <span class="sr-only">Abrir menú principal</span>
            <.icon name="hero-bars-3-solid" class="h-6 w-6" />
          </button>
        </div>
        
    <!-- Menú lateral deslizante -->
        <div
          id={@menu_id}
          role="dialog"
          aria-modal="true"
          aria-label="Menú de navegación"
          hidden
          x-show="menuOpen"
          x-bind:hidden="!menuOpen"
          x-transition:enter="transition-transform ease-out duration-300"
          x-transition:enter-start="-translate-x-full"
          x-transition:enter-end="translate-x-0"
          x-transition:leave="transition-transform ease-in duration-300"
          x-transition:leave-start="translate-x-0"
          x-transition:leave-end="-translate-x-full"
          class={"fixed top-0 left-0 w-72 h-full bg-#{@color_theme}-950 shadow-lg transform z-40 overflow-y-auto"}
          x-cloak
        >
          <!-- Encabezado del menú con botón para cerrar -->
          <div class={"flex items-center justify-between p-4 border-b border-#{@color_theme}-900"}>
            <h2 class="text-xl font-semibold text-white">Menú</h2>
            <button
              @click="menuOpen = false; document.body.classList.remove('overflow-hidden')"
              class={"text-white hover:text-#{@color_theme}-200 focus:outline-none focus:ring-2 focus:ring-#{@color_theme}-300 rounded p-1"}
              aria-label="Cerrar menú"
            >
              <.icon name="hero-x-mark-solid" class="h-6 w-6" />
            </button>
          </div>
          
    <!-- Contenido del menú lateral -->
          <nav aria-label="Menú principal móvil">
            <ul class="py-2">
              <%= for menu <- @menus do %>
                <li class="py-1" x-data="{ open: false }" x-init="$nextTick(() => { open = false })">
                  <%= if menu.submenus do %>
                    <div class="group">
                      <button
                        class={"flex justify-between items-center w-full py-2 px-4 text-white cursor-pointer focus:outline-none focus:bg-#{@color_theme}-800 hover:bg-#{@color_theme}-800 transition-colors duration-200"}
                        @click="open = !open"
                        aria-expanded="false"
                        x-bind:aria-expanded="open.toString()"
                      >
                        <span>{menu.title}</span>
                        <span
                          class="ml-2 w-4 h-4 text-white transition-transform duration-300"
                          x-bind:class="open ? 'rotate-180' : ''"
                        >
                          <.icon name="hero-chevron-down-solid" />
                        </span>
                      </button>
                      <div
                        data-submenu
                        hidden
                        x-show="open"
                        x-bind:hidden="!open"
                        x-cloak
                        class={"mt-0 space-y-1 bg-#{@color_theme}-900"}
                        x-transition:enter="transition ease-out duration-200"
                        x-transition:enter-start="opacity-0 transform -translate-y-2"
                        x-transition:enter-end="opacity-100 transform translate-y-0"
                      >
                        <%= for submenu <- menu.submenus do %>
                          <%= if submenu.submenus do %>
                            <div
                              x-data="{ subOpen: false }"
                              x-init="$nextTick(() => { subOpen = false })"
                            >
                              <button
                                class={"flex justify-between items-center w-full py-2 px-6 text-#{@color_theme}-300 cursor-pointer focus:outline-none focus:bg-#{@color_theme}-800 hover:bg-#{@color_theme}-800 transition-colors duration-200"}
                                @click="subOpen = !subOpen"
                                aria-expanded="false"
                                x-bind:aria-expanded="subOpen.toString()"
                              >
                                <span>{submenu.title}</span>
                                <span
                                  class={"ml-2 w-4 h-4 text-#{@color_theme}-300 transition-transform duration-300"}
                                  x-bind:class="subOpen ? 'rotate-180' : ''"
                                >
                                  <.icon name="hero-chevron-down-solid" />
                                </span>
                              </button>
                              <div
                                data-submenu
                                hidden
                                x-show="subOpen"
                                x-bind:hidden="!subOpen"
                                x-cloak
                                class={"mt-0 space-y-1 bg-#{@color_theme}-800"}
                                x-transition:enter="transition ease-out duration-200"
                                x-transition:enter-start="opacity-0 transform -translate-y-2"
                                x-transition:enter-end="opacity-100 transform translate-y-0"
                              >
                                <%= for subsubmenu <- submenu.submenus do %>
                                  <a
                                    href={subsubmenu.link}
                                    class={"py-2 px-8 block text-#{@color_theme}-300 hover:bg-#{@color_theme}-700 hover:text-white transition-colors duration-200 " <> active_class(@current_path, subsubmenu.link)}
                                  >
                                    {subsubmenu.title}
                                  </a>
                                <% end %>
                              </div>
                            </div>
                          <% else %>
                            <a
                              href={submenu.link}
                              class={"py-2 px-6 block text-#{@color_theme}-300 hover:bg-#{@color_theme}-700 hover:text-white transition-colors duration-200 " <> active_class(@current_path, submenu.link)}
                            >
                              {submenu.title}
                            </a>
                          <% end %>
                        <% end %>
                      </div>
                    </div>
                  <% else %>
                    <a
                      href={menu.link}
                      class={"py-2 px-4 block text-white hover:bg-#{@color_theme}-800 hover:text-#{@color_theme}-200 transition-colors duration-200 " <> active_class(@current_path, menu.link)}
                    >
                      {menu.title}
                    </a>
                  <% end %>
                </li>
              <% end %>
              
    <!-- Sección de autenticación móvil -->
              <li class={"mt-4 border-t border-#{@color_theme}-900 pt-4 pb-2 px-4"}>
                <h3 class={"text-#{@color_theme}-300 text-sm font-semibold uppercase tracking-wider mb-2"}>
                  Mi cuenta
                </h3>
                <%= if @current_user do %>
                  <div class={"flex items-center mb-3 py-1 px-2 bg-#{@color_theme}-900/40 rounded-lg"}>
                    <div class={"w-8 h-8 bg-#{@color_theme}-800 rounded-full flex items-center justify-center mr-2"}>
                      <span class="text-white font-medium text-sm">
                        {String.first(@current_user.username || "")}
                      </span>
                    </div>
                    <span class="text-white text-sm truncate">
                      {@current_user.username || @current_user.email}
                    </span>
                  </div>
                  <div class="space-y-2">
                    <a
                      href="/users/settings"
                      class={"flex items-center py-2 px-2 text-#{@color_theme}-200 hover:bg-#{@color_theme}-800 hover:text-white rounded transition-colors duration-200"}
                    >
                      <.icon name="hero-cog-6-tooth-solid" class="h-5 w-5 mr-2" /> Configuración
                    </a>
                    <form action="/users/log_out" method="post" class="w-full">
                      <input
                        type="hidden"
                        name="_csrf_token"
                        value={Phoenix.Controller.get_csrf_token()}
                      />
                      <button
                        type="submit"
                        class={"flex w-full items-center py-2 px-2 text-#{@color_theme}-200 hover:bg-#{@color_theme}-800 hover:text-white rounded transition-colors duration-200"}
                      >
                        <.icon name="hero-arrow-right-on-rectangle-solid" class="h-5 w-5 mr-2" />
                        Cerrar sesión
                      </button>
                    </form>
                  </div>
                <% else %>
                  <div class="grid grid-cols-1 gap-2">
                    <a
                      href="/users/log_in"
                      class={"flex items-center justify-center py-2 text-white bg-#{@color_theme}-700 hover:bg-#{@color_theme}-600 rounded transition-colors duration-200"}
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                        class="h-5 w-5 mr-1"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3h12.75"
                        />
                      </svg>
                      Iniciar sesión
                    </a>
                    <a
                      href="/users/register"
                      class={"flex items-center justify-center py-2 text-#{@color_theme}-700 bg-white hover:bg-#{@color_theme}-50 rounded transition-colors duration-200"}
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                        class="h-5 w-5 mr-1"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M18 7.5v3m0 0v3m0-3h3m-3 0h-3m-2.25-4.125a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0ZM3 19.235v-.11a6.375 6.375 0 0 1 12.75 0v.109A12.318 12.318 0 0 1 9.374 21c-2.331 0-4.512-.645-6.374-1.766Z"
                        />
                      </svg>
                      Registrarse
                    </a>
                  </div>
                <% end %>
              </li>
            </ul>
          </nav>
        </div>
      </div>
      
    <!-- Versión desktop -->
      <div class="hidden md:block container mx-auto px-4">
        <div class="flex justify-between items-center py-2">
          <!-- Logo o nombre del sitio para desktop -->
          <div class="flex items-center flex-shrink-0 mr-4">
            <a href="/" class="flex items-center text-white">
              <%= if @logo_src do %>
                <img src={@logo_src} alt={@site_name} class="h-10 w-auto mr-2" />
              <% end %>
              <span class="text-white font-semibold text-xl">{@site_name}</span>
            </a>
          </div>
          
    <!-- Menú principal desktop -->
          <nav class="flex-grow flex justify-center" aria-label="Menú principal">
            <ul class="flex justify-center space-x-1 py-3" role="menubar">
              <%= for menu <- @menus do %>
                <li
                  class="relative group"
                  role="none"
                  x-data="{ open: false, timeoutId: null }"
                  x-init="$nextTick(() => { open = false })"
                  @mouseenter="clearTimeout(timeoutId); open = true"
                  @mouseleave="timeoutId = setTimeout(() => { open = false }, 300)"
                >
                  <%= if menu.submenus do %>
                    <button
                      type="button"
                      class={"text-white hover:text-#{@color_theme}-200 flex items-center focus:outline-none focus:ring-2 focus:ring-#{@color_theme}-300 focus:ring-opacity-50 rounded-md px-2 py-1.5 text-sm transition-colors duration-200"}
                      aria-haspopup="true"
                      x-bind:aria-expanded="open.toString()"
                      @click="open = !open"
                      @mouseenter="clearTimeout(timeoutId); open = true"
                      role="menuitem"
                    >
                      <span>{menu.title}</span>

                      <.icon name="hero-chevron-down-solid" class="ml-2 w-4 h-4 text-white" />
                    </button>
                    <ul
                      data-submenu
                      hidden
                      x-show="open"
                      x-bind:hidden="!open"
                      x-cloak
                      @mouseenter="clearTimeout(timeoutId); open = true"
                      @mouseleave="timeoutId = setTimeout(() => { open = false }, 300)"
                      class={"absolute flex-col bg-#{@color_theme}-900 text-#{@color_theme}-300 mt-1 p-2 space-y-1 z-10 min-w-[300px] border border-#{@color_theme}-700 rounded-md shadow-lg"}
                      role="menu"
                      x-transition:enter="transition ease-out duration-200"
                      x-transition:enter-start="opacity-0 transform -translate-y-2"
                      x-transition:enter-end="opacity-100 transform translate-y-0"
                      x-transition:leave="transition ease-in duration-150"
                      x-transition:leave-start="opacity-100"
                      x-transition:leave-end="opacity-0 transform -translate-y-2"
                    >
                      <%= for submenu <- menu.submenus do %>
                        <li
                          class="relative group/submenu"
                          role="none"
                          x-data="{ subOpen: false, subTimeoutId: null }"
                          x-init="$nextTick(() => { subOpen = false })"
                          @mouseenter="clearTimeout(subTimeoutId); subOpen = true"
                          @mouseleave="subTimeoutId = setTimeout(() => { subOpen = false }, 300)"
                        >
                          <%= if submenu.submenus do %>
                            <button
                              type="button"
                              class={"block w-full text-left py-2 px-3 hover:bg-#{@color_theme}-800 rounded-md hover:text-white flex justify-between items-center focus:outline-none focus:bg-#{@color_theme}-700 focus:text-white transition-colors duration-200"}
                              aria-haspopup="true"
                              x-bind:aria-expanded="subOpen.toString()"
                              @mouseenter="clearTimeout(subTimeoutId); subOpen = true"
                              role="menuitem"
                            >
                              <span>{submenu.title}</span>
                              <.icon
                                name="hero-chevron-right-solid"
                                class={"ml-2 w-4 h-4 text-#{@color_theme}-300 group-hover/submenu:text-white transition-colors duration-300"}
                              />
                            </button>
                            <ul
                              data-submenu
                              hidden
                              x-show="subOpen"
                              x-bind:hidden="!subOpen"
                              x-cloak
                              @mouseenter="clearTimeout(subTimeoutId); subOpen = true"
                              @mouseleave="subTimeoutId = setTimeout(() => { subOpen = false }, 300)"
                              class={"absolute flex-col bg-#{@color_theme}-800 text-#{@color_theme}-300 left-full top-0 p-2 space-y-1 z-20 min-w-[300px] border border-#{@color_theme}-700 rounded-md shadow-lg"}
                              style="margin-left: 1px; transform-origin: left center; transform: translateX(0);"
                              role="menu"
                              x-transition:enter="transition ease-out duration-200"
                              x-transition:enter-start="opacity-0 transform -translate-x-2"
                              x-transition:enter-end="opacity-100 transform translate-x-0"
                              x-transition:leave="transition ease-in duration-150"
                              x-transition:leave-start="opacity-100"
                              x-transition:leave-end="opacity-0 transform -translate-x-2"
                            >
                              <%= for subsubmenu <- submenu.submenus do %>
                                <li role="none">
                                  <a
                                    href={subsubmenu.link}
                                    @mouseenter="clearTimeout(subTimeoutId); subOpen = true"
                                    class={"block py-2 px-3 hover:bg-#{@color_theme}-700 rounded-md hover:text-white focus:outline-none focus:bg-#{@color_theme}-600 focus:text-white transition-colors duration-200 " <> active_class(@current_path, subsubmenu.link)}
                                    role="menuitem"
                                  >
                                    {subsubmenu.title}
                                  </a>
                                </li>
                              <% end %>
                            </ul>
                          <% else %>
                            <a
                              href={submenu.link}
                              @mouseenter="clearTimeout(timeoutId); open = true"
                              class={"block py-2 px-3 hover:bg-#{@color_theme}-800 rounded-md hover:text-white focus:outline-none focus:bg-#{@color_theme}-700 focus:text-white transition-colors duration-200 " <> active_class(@current_path, submenu.link)}
                              role="menuitem"
                            >
                              {submenu.title}
                            </a>
                          <% end %>
                        </li>
                      <% end %>
                    </ul>
                  <% else %>
                    <a
                      href={menu.link}
                      class={"text-white hover:text-#{@color_theme}-200 focus:outline-none focus:ring-2 focus:ring-#{@color_theme}-300 focus:ring-opacity-50 rounded-md block px-2 py-1.5 text-sm transition-colors duration-200 " <> active_class(@current_path, menu.link)}
                      role="menuitem"
                    >
                      {menu.title}
                    </a>
                  <% end %>
                </li>
              <% end %>
            </ul>
          </nav>
          
    <!-- Botones de autenticación desktop -->
          <div class="flex items-center space-x-2 flex-shrink-0 ml-4">
            <%= if @current_user do %>
              <div class="relative" x-data="{ open: false }">
                <button
                  @click="open = !open"
                  class={"flex items-center space-x-2 bg-#{@color_theme}-800 hover:bg-#{@color_theme}-700 text-white px-3 py-1.5 rounded-lg transition-colors duration-200"}
                >
                  <div class={"w-6 h-6 rounded-full bg-#{@color_theme}-600 flex items-center justify-center"}>
                    <span class="text-white text-xs font-medium">
                      {String.first(@current_user.username || "")}
                    </span>
                  </div>
                  <span class="text-sm hidden xl:inline max-w-[120px] truncate">
                    {@current_user.username || @current_user.email}
                  </span>
                  <.icon name="hero-chevron-down-solid" class="w-4 h-4" />
                </button>

                <div
                  x-show="open"
                  @click.outside="open = false"
                  x-transition:enter="transition ease-out duration-100"
                  x-transition:enter-start="transform opacity-0 scale-95"
                  x-transition:enter-end="transform opacity-100 scale-100"
                  x-transition:leave="transition ease-in duration-75"
                  x-transition:leave-start="transform opacity-100 scale-100"
                  x-transition:leave-end="transform opacity-0 scale-95"
                  class="absolute right-0 w-48 py-2 mt-1 bg-white rounded-md shadow-xl z-50 border border-gray-200"
                  x-cloak
                >
                  <a
                    href="/users/settings"
                    class={"flex items-center px-4 py-2 text-gray-700 hover:bg-#{@color_theme}-50"}
                  >
                    <.icon
                      name="hero-cog-6-tooth-solid"
                      class={"w-5 h-5 mr-2 text-#{@color_theme}-700"}
                    /> Configuración
                  </a>
                  <form action="/users/log_out" method="post" class="w-full">
                    <input
                      type="hidden"
                      name="_csrf_token"
                      value={Phoenix.Controller.get_csrf_token()}
                    />
                    <button
                      type="submit"
                      class={"flex w-full items-center px-4 py-2 text-gray-700 hover:bg-#{@color_theme}-50"}
                    >
                      <.icon
                        name="hero-arrow-right-on-rectangle-solid"
                        class={"w-5 h-5 mr-2 text-#{@color_theme}-700"}
                      /> Cerrar sesión
                    </button>
                  </form>
                </div>
              </div>
            <% else %>
              <div class="flex items-center space-x-3">
                <a
                  href="/users/log_in"
                  class={"text-white hover:text-#{@color_theme}-200 text-sm font-medium transition-colors duration-200"}
                >
                  Iniciar sesión
                </a>
                <a
                  href="/users/register"
                  class={"bg-white text-#{@color_theme}-700 hover:bg-opacity-90 text-sm font-medium px-3 py-1.5 rounded-md shadow-sm hover:shadow-md transform hover:-translate-y-0.5 transition-all duration-200 border border-transparent hover:border-white/20"}
                >
                  Registrarse
                </a>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Componente para articulo unico
  attr :image_src, :string, required: true, doc: "Ruta de la imagen destacada"
  attr :image_alt, :string, default: "Imagen destacada", doc: "Texto alternativo para la imagen"
  attr :date, :string, required: true, doc: "Fecha de publicación (formato: '01 Abril 2025')"
  attr :time, :string, required: true, doc: "Hora de publicación (formato: '02:49 AM')"
  attr :author, :string, required: true, doc: "Nombre del autor"
  attr :title, :string, required: true, doc: "Título del artículo"
  attr :category, :string, default: nil, doc: "Categoría del artículo"
  attr :category_url, :string, default: nil, doc: "URL de la categoría para hacerla clickeable"
  attr :comment_count, :integer, default: 0, doc: "Número de comentarios"

  attr :show_footer, :boolean,
    default: true,
    doc: "Mostrar o no el pie de página con opciones de compartir"

  attr :class, :string, default: "", doc: "Clases CSS adicionales"
  slot :inner_block, required: true, doc: "Contenido del artículo"

  def single_article(assigns) do
    assigns =
      assigns
      |> assign(:color_theme, Config.webpage_theme())

    ~H"""
    <article class={"bg-white text-gray-800 px-4 py-6 md:px-8 md:py-8 lg:px-12 lg:py-10 rounded-lg shadow-md border-t-4 border-#{@color_theme}-600 #{@class}"}>
      <!-- Layout flexible: columnas en pantallas grandes, apilado en móviles -->
      <div class="flex flex-col md:flex-row md:gap-8">
        <!-- Columna de imagen (más pequeña en desktop) -->
        <div class="mb-6 md:mb-0 md:w-2/5 lg:w-1/3 flex-shrink-0">
          <div
            x-data="{ showModal: false }"
            class="relative rounded-lg overflow-hidden shadow-md h-64 md:h-80 group"
          >
            <img
              src={@image_src}
              alt={@image_alt}
              class="absolute inset-0 w-full h-full object-cover"
            />
            <div class={"absolute inset-0 border-2 border-#{@color_theme}-200 opacity-50 pointer-events-none rounded-lg"}>
            </div>
            
    <!-- Botón de lupa - Visible solo en hover -->
            <div class="absolute inset-0 flex items-center justify-center">
              <button
                @click="showModal = true"
                type="button"
                class={"p-3 rounded-full bg-#{@color_theme}-900 bg-opacity-70 hover:bg-opacity-90 text-white opacity-0 group-hover:opacity-100 transition-all duration-300 transform scale-90 group-hover:scale-100 cursor-pointer"}
                aria-label="Ver imagen ampliada"
              >
                <.icon name="hero-magnifying-glass-plus-solid" class="h-8 w-8" />
              </button>
            </div>
            
    <!-- Modal de imagen ampliada -->
            <div
              x-show="showModal"
              x-cloak
              class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 md:p-12"
              @keydown.escape.window="showModal = false"
              role="dialog"
              aria-modal="true"
            >
              <div
                class="fixed inset-0 bg-black bg-opacity-80 transition-opacity"
                @click="showModal = false"
              >
              </div>

              <div
                class="relative max-w-5xl w-full max-h-[90vh] bg-white rounded-lg shadow-2xl overflow-hidden transform"
                @click.outside="showModal = false"
              >
                <div class="relative h-full w-full flex items-center justify-center bg-gray-100">
                  <img
                    src={@image_src}
                    alt={@image_alt}
                    class="max-h-[80vh] max-w-full object-contain"
                  />
                </div>

                <button
                  type="button"
                  class="absolute top-3 right-3 text-white bg-black bg-opacity-50 hover:bg-opacity-70 rounded-full p-2 focus:outline-none focus:ring-2 focus:ring-white"
                  @click="showModal = false"
                  aria-label="Cerrar"
                >
                  <.icon name="hero-x-mark-solid" class="h-6 w-6" />
                </button>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Columna de contenido -->
        <div class="flex-grow">
          <!-- Fecha, hora y autor -->
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center text-gray-500 text-sm mb-4">
            <p class="mb-2 sm:mb-0">
              <span class={"text-#{@color_theme}-800"}>Publicado el:</span>
              <span class="font-medium">{@date}</span>
              <span class={"text-#{@color_theme}-800 ml-1"}>a las</span>
              <span class="font-medium">{@time}</span>
            </p>
            <p>
              <span class={"text-#{@color_theme}-800"}>Por:</span>
              <a
                href="#"
                class={"font-medium text-#{@color_theme}-700 hover:text-#{@color_theme}-900 hover:underline transition-colors duration-200"}
              >
                {@author}
              </a>
            </p>
          </div>
          
    <!-- Título -->
          <h1 class={"text-2xl sm:text-3xl font-bold mb-4 text-#{@color_theme}-950"}>
            {@title}
          </h1>
          
    <!-- Categoría -->
          <%= if @category do %>
            <div class="mb-6">
              <%= if @category_url do %>
                <.link href={@category_url}>
                  <.badge text={@category} color={assigns.color_theme} size="md" />
                </.link>
              <% else %>
                <.badge text={@category} color={assigns.color_theme} size="md" />
              <% end %>
            </div>
          <% end %>
          
    <!-- Contenido -->
          <div class="text-gray-700 leading-relaxed space-y-4">
            {render_slot(@inner_block)}
          </div>
        </div>
      </div>
      
    <!-- Pie de página (opcional) -->
      <%= if @show_footer do %>
        <div class="mt-8 pt-4 border-t border-gray-200">
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
            <!-- Botones de compartir -->
            <div class="flex flex-wrap gap-3">
              <a
                href="#"
                class={"inline-flex items-center text-#{@color_theme}-700 hover:text-#{@color_theme}-900 text-sm font-medium transition-colors duration-200"}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  class="h-5 w-5 mr-1"
                >
                  <path d="M13.6823 10.6218L20.2391 3H18.6854L12.9921 9.61788L8.44486 3H3.2002L10.0765 13.0074L3.2002 21H4.75404L10.7663 14.0113L15.5685 21H20.8131L13.6819 10.6218H13.6823ZM11.5541 13.0956L10.8574 12.0991L5.31391 4.16971H7.70053L12.1742 10.5689L12.8709 11.5655L18.6861 19.8835H16.2995L11.5541 13.096V13.0956Z" />
                </svg>
                X (Twitter)
              </a>
              <a
                href="#"
                class={"inline-flex items-center text-#{@color_theme}-700 hover:text-#{@color_theme}-900 text-sm font-medium transition-colors duration-200"}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  class="h-5 w-5 mr-1"
                >
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                </svg>
                Facebook
              </a>
              <a
                href="#"
                class={"inline-flex items-center text-#{@color_theme}-700 hover:text-#{@color_theme}-900 text-sm font-medium transition-colors duration-200"}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                  class="h-5 w-5 mr-1"
                >
                  <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z" />
                </svg>
                Instagram
              </a>
            </div>
            <!-- Comentarios con icono -->
            <div class="flex items-center">
              <a
                href="#comentarios"
                class={"inline-flex items-center text-#{@color_theme}-700 hover:text-#{@color_theme}-900 transition-colors duration-200"}
              >
                <.icon name="hero-chat-bubble-bottom-center-text" class="h-5 w-5 mr-1" />
                <span class="text-sm font-medium">{@comment_count} comentarios</span>
              </a>
            </div>
          </div>
        </div>
      <% end %>
    </article>
    """
  end

  # Componente para el pie de pagina (footer)
  attr :sitename, :string, doc: "Nombre del sitio que aparecerá en el footer"

  attr :slogan, :string,
    default: "Trabajando por nuestra provincia",
    doc: "Eslogan o descripción corta de la organización"

  attr :logo_src, :string,
    default: "",
    doc: "URL del logo, si es nil se usará un ícono SVG por defecto"

  attr :address, :string, doc: "Dirección física de la organización"

  attr :phone, :string, doc: "Número de teléfono principal"

  attr :emails, :list, doc: "Lista de direcciones de correo electrónico"

  attr :copyright_year, :string,
    default: "2025",
    doc: "Año para mostrar en el aviso de copyright"

  attr :social_links, :list, doc: "Lista de enlaces de redes sociales con nombre, URL e ícono"

  attr :menu_columns, :list,
    default: [
      %{
        title: "Ministerios",
        links: [
          %{text: "Seguridad y Justicia", url: "#"},
          %{text: "Agricultura", url: "#"},
          %{text: "Desarrollo Social", url: "#"},
          %{text: "Economía", url: "#"},
          %{text: "Autoridades Provinciales", url: "#"}
        ]
      },
      %{
        title: "Información y Servicios",
        links: [
          %{text: "Compras y Licitaciones", url: "#"},
          %{text: "Transferencias a Municipios", url: "#"},
          %{text: "Consulta de Expedientes", url: "#"},
          %{text: "Deuda Pública", url: "#"},
          %{text: "Presupuesto Fiscal", url: "#"}
        ]
      },
      %{
        title: "Sitios Oficiales",
        links: [
          %{text: "Agencia de Recaudación", url: "#"},
          %{text: "Aguas Rionegrinas", url: "#"},
          %{text: "Casa de Río Negro", url: "#"},
          %{text: "Defensa Civil", url: "#"},
          %{text: "Educación", url: "#"}
        ]
      },
      %{
        title: "Enlaces Rápidos",
        links: [
          %{text: "Preguntas Frecuentes", url: "#", icon: "info"},
          %{text: "Contacto", url: "#", icon: "phone"},
          %{text: "Portal del Empleado", url: "#", icon: "user"},
          %{text: "Noticias", url: "#", icon: "news"},
          %{text: "Calendario de Actividades", url: "#", icon: "calendar"}
        ]
      }
    ],
    doc: "Columnas del menú del footer con título y enlaces"

  attr :legal_links, :list,
    default: [
      %{text: "Términos y Condiciones", url: "#"},
      %{text: "Política de Privacidad", url: "#"},
      %{text: "Mapa del Sitio", url: "#"}
    ],
    doc: "Enlaces legales en la parte inferior del footer"

  attr :class, :string,
    default: "",
    doc: "Clases CSS adicionales para el contenedor principal"

  def site_footer(assigns) do
    # Valores por defecto tomados del config
    assigns =
      assigns
      |> assign_new(:sitename, fn -> Config.institution_name() end)
      |> assign_new(:slogan, fn -> Config.institution_slogan() end)
      |> assign_new(:emails, fn -> Config.institution_emails() end)
      |> assign_new(:social_links, fn -> Config.institution_social_links() end)
      |> assign_new(:phone, fn -> Config.institution_phone() end)
      |> assign_new(:address, fn -> Config.institution_address() end)
      |> assign(:color_theme, Config.webpage_theme())

    ~H"""
    <footer class={"bg-#{@color_theme}-950 text-white py-8 px-4 sm:px-6 border-t-4 border-#{@color_theme}-700 #{@class}"}>
      <div class="container mx-auto">
        <!-- Logo y texto de descripción -->
        <div class="flex flex-col items-center md:flex-row md:justify-between mb-8">
          <div class="flex items-center mb-6 md:mb-0">
            <!-- Logo (SVG por defecto o personalizado) -->
            <div class="bg-white p-2 rounded-lg mr-3">
              <%= if @logo_src && String.length(@logo_src) > 0 do %>
                <img src={@logo_src} alt={@sitename} class="h-10 w-10" />
              <% else %>
                <.icon name="hero-home-solid" class={"h-10 w-10 text-#{@color_theme}-950"} />
              <% end %>
            </div>
            <div>
              <h2 class="text-xl font-bold">{@sitename}</h2>
              <p class={"text-#{@color_theme}-300 text-sm"}>{@slogan}</p>
            </div>
          </div>
          
    <!-- Redes sociales -->
          <div>
            <h3 class={"text-sm font-semibold mb-2 uppercase tracking-wider text-#{@color_theme}-300"}>
              Síguenos
            </h3>
            <div class="flex space-x-4">
              <%= if Enum.find(@social_links, fn s -> s.name == "Twitter" || s.name == "X" end) do %>
                <% twitter =
                  Enum.find(@social_links, fn s -> s.name == "Twitter" || s.name == "X" end) %>
                <a
                  href={twitter.url}
                  target="_blank"
                  aria-label="X (Twitter)"
                  class={"bg-#{@color_theme}-900 hover:bg-#{@color_theme}-800 p-2 rounded-full transition-colors duration-200"}
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="20"
                    height="20"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    class="h-5 w-5"
                  >
                    <path d="M13.6823 10.6218L20.2391 3H18.6854L12.9921 9.61788L8.44486 3H3.2002L10.0765 13.0074L3.2002 21H4.75404L10.7663 14.0113L15.5685 21H20.8131L13.6819 10.6218H13.6823ZM11.5541 13.0956L10.8574 12.0991L5.31391 4.16971H7.70053L12.1742 10.5689L12.8709 11.5655L18.6861 19.8835H16.2995L11.5541 13.096V13.0956Z" />
                  </svg>
                </a>
              <% end %>

              <%= if Enum.find(@social_links, fn s -> s.name == "Facebook" end) do %>
                <% facebook = Enum.find(@social_links, fn s -> s.name == "Facebook" end) %>
                <a
                  href={facebook.url}
                  target="_blank"
                  aria-label="Facebook"
                  class={"bg-#{@color_theme}-900 hover:bg-#{@color_theme}-800 p-2 rounded-full transition-colors duration-200"}
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="20"
                    height="20"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    class="h-5 w-5"
                  >
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                  </svg>
                </a>
              <% end %>

              <%= if Enum.find(@social_links, fn s -> s.name == "Instagram" end) do %>
                <% instagram = Enum.find(@social_links, fn s -> s.name == "Instagram" end) %>
                <a
                  href={instagram.url}
                  target="_blank"
                  aria-label="Instagram"
                  class={"bg-#{@color_theme}-900 hover:bg-#{@color_theme}-800 p-2 rounded-full transition-colors duration-200"}
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="20"
                    height="20"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    class="h-5 w-5"
                  >
                    <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z" />
                  </svg>
                </a>
              <% end %>

              <%= if Enum.find(@social_links, fn s -> s.name == "YouTube" end) do %>
                <% youtube = Enum.find(@social_links, fn s -> s.name == "YouTube" end) %>
                <a
                  href={youtube.url}
                  target="_blank"
                  aria-label="YouTube"
                  class={"bg-#{@color_theme}-900 hover:bg-#{@color_theme}-800 p-2 rounded-full transition-colors duration-200"}
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="20"
                    height="20"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    class="h-5 w-5"
                  >
                    <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
                  </svg>
                </a>
              <% end %>
            </div>
          </div>
        </div>
        
    <!-- Grid de enlaces -->
        <div class={"grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 border-b border-#{@color_theme}-900 pb-8 mb-6"}>
          <%= for column <- @menu_columns do %>
            <div>
              <h3 class={"text-lg font-bold mb-4 border-b border-#{@color_theme}-800 pb-2 text-#{@color_theme}-200"}>
                {column.title}
              </h3>
              <ul class="space-y-2">
                <%= for link <- column.links do %>
                  <li>
                    <a
                      href={link.url}
                      class="text-gray-300 hover:text-white hover:underline transition-colors duration-200 flex items-center"
                    >
                      <%= if link[:icon] do %>
                        <.icon name={link[:icon]} class={"h-4 w-4 mr-2 text-#{@color_theme}-400"} />
                      <% else %>
                        <.icon
                          name="hero-arrow-right-solid"
                          class={"h-5 w-5 mr-2 text-#{@color_theme}-400"}
                        />
                      <% end %>

                      {link.text}
                    </a>
                  </li>
                <% end %>
              </ul>
            </div>
          <% end %>
        </div>
        
    <!-- Información de contacto -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          <div class="flex items-start">
            <.icon
              name="hero-map-pin-solid"
              class={"h-5 w-5 mr-3 text-#{@color_theme}-400 mt-1 flex-shrink-0"}
            />
            <div>
              <h4 class={"text-#{@color_theme}-200 font-semibold mb-1"}>Dirección</h4>
              <p class="text-sm text-gray-300">{@address}</p>
            </div>
          </div>

          <div class="flex items-start">
            <.icon
              name="hero-phone-solid"
              class={"h-5 w-5 mr-3 text-#{@color_theme}-400 mt-1 flex-shrink-0"}
            />
            <div>
              <h4 class={"text-#{@color_theme}-200 font-semibold mb-1"}>Teléfono</h4>
              <p class="text-sm text-gray-300">{@phone}</p>
            </div>
          </div>

          <div class="flex items-start">
            <.icon
              name="hero-envelope-solid"
              class={"h-5 w-5 mr-3 text-#{@color_theme}-400 mt-1 flex-shrink-0"}
            />
            <div>
              <h4 class={"text-#{@color_theme}-200 font-semibold mb-1"}>Email</h4>
              <%= for email <- @emails do %>
                <p class="text-sm text-gray-300">{email}</p>
              <% end %>
            </div>
          </div>
        </div>
        
    <!-- Derechos y política de privacidad -->
        <div class={"border-t border-#{@color_theme}-900 pt-6 flex flex-col sm:flex-row justify-between items-center"}>
          <p class="text-sm text-gray-400 mb-4 sm:mb-0">
            © {@copyright_year} {@sitename}. Todos los derechos reservados.
          </p>
          <div class="flex space-x-6">
            <%= for link <- @legal_links do %>
              <a
                href={link.url}
                class="text-sm text-gray-400 hover:text-white hover:underline transition-colors duration-200"
              >
                {link.text}
              </a>
            <% end %>
          </div>
        </div>
      </div>
    </footer>
    """
  end

  # Componente para el slider
  attr :images, :list,
    default: [],
    doc: "Lista de URLs de imágenes para el slider"

  attr :captions, :list,
    default: [],
    doc: "Lista de títulos/descripciones para cada imagen (opcional)"

  attr :auto_slide, :boolean,
    default: true,
    doc: "Habilita el deslizamiento automático entre imágenes"

  attr :slide_interval, :integer,
    default: 5000,
    doc: "Tiempo en milisegundos entre los deslizamientos automáticos"

  attr :height, :string,
    default: "h-96 md:h-[500px]",
    doc: "Altura del slider (clases de Tailwind)"

  attr :rounded, :boolean,
    default: true,
    doc: "Si el slider debe tener bordes redondeados"

  def slider(assigns) do
    assigns =
      assigns
      |> assign(
        x_data: %{
          current: 0,
          totalSlides: length(assigns.images),
          autoSlide: assigns.auto_slide,
          slideInterval: assigns.slide_interval,
          paused: false
        }
      )
      |> assign(:color_theme, Config.webpage_theme())

    ~H"""
    <div
      x-data={Jason.encode!(@x_data)}
      x-init="
        if (autoSlide && !paused) {
          slideTimer = setInterval(() => {
            current = (current + 1) % totalSlides;
          }, slideInterval);
        }

        $watch('paused', (value) => {
          if (value) {
            clearInterval(slideTimer);
          } else if (autoSlide) {
            slideTimer = setInterval(() => {
              current = (current + 1) % totalSlides;
            }, slideInterval);
          }
        });
      "
      @mouseenter="paused = true"
      @mouseleave="paused = false"
      class={"relative w-full overflow-hidden #{@height} #{if @rounded, do: "rounded-lg", else: ""} shadow-xl mb-8 border-2 border-#{@color_theme}-200 bg-#{@color_theme}-950"}
    >
      <!-- Slider principal -->
      <div
        class="flex h-full transition-transform duration-700 ease-in-out"
        x-bind:style="'transform: translateX(-' + (current * 100) + '%)'"
      >
        <%= for {image, index} <- Enum.with_index(@images) do %>
          <div class="flex-shrink-0 w-full h-full relative">
            <img src={image} alt={"Slide #{index + 1}"} class="w-full h-full object-cover" />
            <!-- Gradiente superpuesto -->
            <div class={"absolute inset-0 bg-gradient-to-t from-#{@color_theme}-950/70 to-transparent"}>
            </div>
            
    <!-- Leyenda de la imagen si existe -->
            <%= if Enum.at(@captions, index) do %>
              <div class="absolute bottom-12 left-0 right-0 p-4 md:p-6 text-white">
                <div class="max-w-4xl mx-auto">
                  <h3 class="text-xl md:text-2xl font-bold mb-2 drop-shadow-lg">
                    {Enum.at(@captions, index)[:title] || ""}
                  </h3>
                  <p class="text-sm md:text-base drop-shadow-lg">
                    {Enum.at(@captions, index)[:description] || ""}
                  </p>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
      
    <!-- Controles de navegación -->
      <button
        @click="current = (current - 1 + totalSlides) % totalSlides"
        class={"absolute left-4 top-1/2 transform -translate-y-1/2 bg-#{@color_theme}-800/70 hover:bg-#{@color_theme}-700 text-white w-10 h-10 rounded-full flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 transition-all duration-200"}
        aria-label="Imagen anterior"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-6 w-6"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
        </svg>
      </button>
      <button
        @click="current = (current + 1) % totalSlides"
        class={"absolute right-4 top-1/2 transform -translate-y-1/2 bg-#{@color_theme}-800/70 hover:bg-#{@color_theme}-700 text-white w-10 h-10 rounded-full flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-#{@color_theme}-500 focus:ring-opacity-50 transition-all duration-200"}
        aria-label="Imagen siguiente"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-6 w-6"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
        </svg>
      </button>
      
    <!-- Indicadores de posición -->
      <div class="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-3">
        <%= for {_image, index} <- Enum.with_index(@images) do %>
          <button
            @click={"current = " <> Integer.to_string(index)}
            class={"w-3 h-3 rounded-full transition-all duration-300 bg-#{@color_theme}/50 hover:bg-white/80"}
            x-bind:class={"current === " <> Integer.to_string(index) <> " ? 'bg-" <> assigns.color_theme <> "-500 scale-150' : 'bg-white/50 hover:bg-white/80'"}
            aria-label={"Ir a la imagen #{index + 1}"}
          >
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  # Componente para layout dinamico (una o dos columnas)
  attr :title, :string, default: nil, doc: "Título principal de la sección de contenido"
  attr :subtitle, :string, default: nil, doc: "Subtítulo opcional de la sección"
  attr :has_sidebar, :boolean, default: true, doc: "Si debe mostrar la barra lateral"
  attr :wrapper_class, :string, default: "", doc: "Clases adicionales para el contenedor externo"
  slot :hero, doc: "Contenido destacado (slider, banner, etc.)"
  slot :sidebar, doc: "Contenido de la barra lateral"
  slot :inner_block, required: true, doc: "Contenido principal"

  def content_layout(assigns) do
    assigns =
      assigns
      |> assign(
        :color_theme,
        Config.webpage_theme()
      )

    ~H"""
    <div>
      <%= if @title do %>
        <div class="mb-8 text-center">
          <h1 class={"text-3xl sm:text-4xl font-bold text-#{@color_theme}-950 mb-2"}>{@title}</h1>
          <%= if @subtitle do %>
            <p class={"text-lg text-#{@color_theme}-700"}>{@subtitle}</p>
          <% end %>
          <div class={"w-20 h-1 bg-#{@color_theme}-600 mx-auto mt-4"}></div>
        </div>
      <% end %>
      
    <!-- Área para contenido destacado (slider) -->
      <%= if render_slot(@hero) do %>
        <div class="mb-8">
          {render_slot(@hero)}
        </div>
      <% end %>
      
    <!-- Layout principal con contenido y barra lateral (si existe) -->
      <div class={"grid gap-8 " <> if(@has_sidebar && render_slot(@sidebar), do: "grid-cols-1 lg:grid-cols-3", else: "")}>
        <div class={if(@has_sidebar && render_slot(@sidebar), do: "lg:col-span-2", else: "")}>
          <div class={"bg-white rounded-lg shadow-md p-4 sm:p-6 border border-#{@color_theme}-100"}>
            {render_slot(@inner_block)}
          </div>
        </div>

        <%= if @has_sidebar && render_slot(@sidebar) do %>
          <div class="lg:col-span-1">
            {render_slot(@sidebar)}
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Componente para tarjetas de la barra lateral
  attr :title, :string, default: "Enlaces de interés", doc: "Título de la barra lateral"

  attr :icon, :string,
    default: nil,
    doc: "Ícono opcional para el encabezado (admin, users, shield, etc.)"

  attr :highlight, :boolean, default: false, doc: "Si se debe destacar visualmente (estilo admin)"

  attr :highlight_color, :string,
    default: nil,
    doc: "Color para destacar (si es diferente al tema del sitio)"

  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  attr :role_name, :string,
    default: nil,
    doc: "Nombre del rol para mostrar (cuando highlight=true)"

  slot :inner_block, required: true, doc: "Contenido de la barra lateral"

  def sidebar_box(assigns) do
    # Obtenemos el color_theme
    color_theme = Config.webpage_theme()

    # Asignamos color_theme
    assigns = assign(assigns, :color_theme, color_theme)

    # Verificamos explícitamente si highlight_color está presente o es nil
    # Si no está presente o es nil, asignamos el color_theme
    highlight_color = Map.get(assigns, :highlight_color)

    assigns =
      if is_nil(highlight_color) do
        assign(assigns, :highlight_color, color_theme)
      else
        assigns
      end

    ~H"""
    <%= if @highlight do %>
      <!-- Versión destacada del box (estilo admin) -->
      <div class={"bg-white rounded-lg shadow-md overflow-hidden border-2 border-#{@highlight_color}-400 #{@class}"}>
        <div class={"bg-gradient-to-r from-#{@highlight_color}-600 to-#{@highlight_color}-700 text-white p-4 flex items-center"}>
          <%= if @icon do %>
            <%= case @icon do %>
              <% "users" -> %>
                <.icon name="hero-user-group-solid" class="h-5 w-5 mr-2" />
              <% "shield" -> %>
                <.icon name="hero-shield-check-solid" class="h-5 w-5 mr-2" />
              <% "key" -> %>
                <.icon name="hero-key-solid" class="h-5 w-5 mr-2" />
              <% "lock" -> %>
                <.icon name="hero-lock-closed-solid" class="h-5 w-5 mr-2" />
              <% "admin" -> %>
                <.icon name="hero-cog-6-tooth-solid" class="h-5 w-5 mr-2" />
              <% _ -> %>
                <.icon name="hero-cog-6-tooth-solid" class="h-5 w-5 mr-2" />
            <% end %>
          <% end %>
          <div class="flex-1">
            <h2 class="font-semibold text-lg">{@title}</h2>
            <%= if @role_name do %>
              <span class={"text-xs font-medium text-#{@highlight_color}-100"}>
                Rol: {@role_name}
              </span>
            <% end %>
          </div>
        </div>
        <div class={"p-4 border-t-2 border-#{@highlight_color}-100"}>
          {render_slot(@inner_block)}
        </div>
      </div>
    <% else %>
      <!-- Versión estándar original del box -->
      <div class={"bg-white rounded-lg shadow-md border border-#{@color_theme}-100 overflow-hidden #{@class}"}>
        <div class={"bg-#{@color_theme}-900 text-white p-4"}>
          <h2 class="font-semibold text-lg">{@title}</h2>
        </div>
        <div class="p-4">
          {render_slot(@inner_block)}
        </div>
      </div>
    <% end %>
    """
  end

  # Componente para enlaces destacados en la barra lateral
  attr :items, :list, default: [], doc: "Lista de ítems con :icon, :title y :url"

  def sidebar_links(assigns) do
    assigns =
      assigns
      |> assign(
        :color_theme,
        Config.webpage_theme()
      )

    ~H"""
    <ul class="space-y-2">
      <%= for item <- @items do %>
        <li>
          <a
            href={item.url}
            class={"flex items-center p-3 rounded-md transition-colors duration-200 hover:bg-#{@color_theme}-50 border border-transparent hover:border-#{@color_theme}-200 group"}
          >
            <%= if item[:icon] do %>
              <div class={"w-10 h-10 flex-shrink-0 flex items-center justify-center rounded-full bg-#{@color_theme}-100 text-#{@color_theme}-800 group-hover:bg-#{@color_theme}-200 mr-3"}>
                <%= case item.icon do %>
                  <% "info" -> %>
                    <.icon name="hero-information-circle-solid" class="h-5 w-5" />
                  <% "doc" -> %>
                    <.icon name="hero-document-text-solid" class="h-5 w-5" />
                  <% "calendar" -> %>
                    <.icon name="hero-calendar-solid" class="h-5 w-5" />
                  <% "alert" -> %>
                    <.icon name="hero-exclamation-circle-solid" class="h-5 w-5" />
                  <% _ -> %>
                    <.icon name="hero-arrow-right-solid" class="h-5 w-5" />
                <% end %>
              </div>
            <% end %>
            <div>
              <span class={"font-medium text-#{@color_theme}-900 group-hover:text-#{@color_theme}-700"}>
                {item.title}
              </span>
              <%= if item[:description] do %>
                <p class="text-sm text-gray-500">{item.description}</p>
              <% end %>
            </div>
          </a>
        </li>
      <% end %>
    </ul>
    """
  end

  # Componente para las tarjetas de articulos
  attr :title, :string, required: true, doc: "Título del artículo"
  attr :date, :string, required: true, doc: "Fecha de publicación"
  attr :image, :string, default: nil, doc: "Imagen destacada (opcional)"
  attr :image_alt, :string, default: nil, doc: "Texto alternativo para la imagen"
  attr :excerpt, :string, default: "", doc: "Extracto del artículo"
  attr :url, :string, required: true, doc: "URL del artículo completo"
  attr :category, :string, default: nil, doc: "Categoría del artículo"
  attr :author, :string, default: nil, doc: "Autor del artículo"
  attr :actions, :list, default: [], doc: "Lista de acciones (editar, eliminar, etc.)"
  attr :featured, :boolean, default: false, doc: "Si el artículo está destacado de la semana"
  attr :id, :integer, default: nil, doc: "ID del artículo para acciones"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  def article_card(assigns) do
    assigns =
      assigns
      |> assign_new(:color_theme, fn -> Config.webpage_theme() end)
      |> assign_new(:image_alt, fn -> assigns[:title] end)

    ~H"""
    <div class={"bg-white rounded-lg overflow-hidden shadow-md hover:shadow-lg transition-shadow duration-300 border border-#{@color_theme}-100 flex flex-col h-full group #{@class}"}>
      <%= if @image do %>
        <div
          class="relative h-48 overflow-hidden"
          x-data="{ showModal: false, isHovered: false }"
          x-init="$nextTick(() => { showModal = false })"
          @mouseenter="isHovered = true; $refs.lupaBtn.classList.add('opacity-100')"
          @mouseleave="isHovered = false; $refs.lupaBtn.classList.remove('opacity-100')"
        >
          <!-- Imagen sin comportamiento de clic -->
          <img
            src={@image}
            alt={@image_alt}
            class="w-full h-full object-cover transition-transform duration-300"
            x-bind:class="{ 'scale-105': isHovered }"
          />
          
    <!-- Botón de lupa exclusivo para abrir el modal -->
          <button
            type="button"
            x-ref="lupaBtn"
            class={"absolute top-2 left-2 bg-#{@color_theme}-900 bg-opacity-70 hover:bg-opacity-90 text-white flex items-center justify-center w-8 h-8 rounded-full z-30 opacity-0 transition-opacity duration-300 cursor-pointer"}
            @click="showModal = true"
            aria-label="Ver imagen ampliada"
          >
            <.icon name="hero-magnifying-glass-plus" class="h-4 w-4" />
          </button>
          
    <!-- Enlace al artículo (SOLO en el título, no en la imagen) -->
          <%= if @category do %>
            <div class="absolute top-2 right-2 z-30">
              <.badge text={@category} color={assigns.color_theme} size="sm" />
            </div>
          <% end %>
          
    <!-- Modal de imagen ampliada -->
          <div x-show="showModal" x-cloak>
            <div
              class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 md:p-12"
              @keydown.escape.window="showModal = false"
              role="dialog"
              aria-modal="true"
            >
              <div
                class="fixed inset-0 bg-black bg-opacity-80 transition-opacity"
                x-transition:enter="transition ease-out duration-300"
                x-transition:enter-start="opacity-0"
                x-transition:enter-end="opacity-100"
                x-transition:leave="transition ease-in duration-200"
                x-transition:leave-start="opacity-100"
                x-transition:leave-end="opacity-0"
                @click="showModal = false"
              >
              </div>

              <div
                class="relative max-w-5xl w-full max-h-[90vh] bg-white rounded-lg shadow-2xl overflow-hidden transform"
                x-transition:enter="transition ease-out duration-300"
                x-transition:enter-start="opacity-0 scale-95"
                x-transition:enter-end="opacity-100 scale-100"
                x-transition:leave="transition ease-in duration-200"
                x-transition:leave-start="opacity-100 scale-100"
                x-transition:leave-end="opacity-0 scale-95"
                @click.outside="showModal = false"
              >
                <div class="relative h-full w-full flex items-center justify-center bg-gray-100">
                  <img src={@image} alt={@image_alt} class="max-h-[80vh] max-w-full object-contain" />
                </div>

                <button
                  type="button"
                  class="absolute top-3 right-3 text-white bg-black bg-opacity-50 hover:bg-opacity-70 rounded-full p-2 focus:outline-none focus:ring-2 focus:ring-white"
                  @click.stop="showModal = false"
                  aria-label="Cerrar"
                >
                  <.icon name="hero-x-mark-solid" class="h-6 w-6" />
                </button>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <div class="p-4 flex-grow">
        <div class="flex justify-between items-center mb-2">
          <div class={"text-sm text-#{@color_theme}-700"}>{@date}</div>
          <%= if @featured do %>
            <div class="bg-yellow-100 text-yellow-800 text-xs px-2 py-1 rounded-full flex items-center">
              <.icon name="hero-star-solid" class="h-3 w-3 mr-1" />
              <span>Destacado</span>
            </div>
          <% end %>
        </div>
        <h3 class={"font-bold text-lg text-#{@color_theme}-950 mb-2 group-hover:text-#{@color_theme}-700"}>
          <.link href={@url} class="hover:underline">{@title}</.link>
        </h3>
        <p class="text-gray-600 text-sm line-clamp-3 mb-4">{@excerpt}</p>
      </div>

      <div class="px-4 pb-4 mt-auto border-t border-gray-100 pt-2">
        <%= if @author do %>
          <div class="text-xs text-gray-500 mb-2">
            Por {@author}
          </div>
        <% end %>

        <div class="flex justify-between items-center">
          <.link
            href={@url}
            class={"inline-flex items-center text-sm font-semibold text-#{@color_theme}-700 hover:text-#{@color_theme}-900"}
          >
            Leer más <.icon name="hero-arrow-right" class="h-4 w-4 ml-1" />
          </.link>

          <%= if length(@actions) > 0 do %>
            <div class="flex space-x-2">
              <%= for action <- @actions do %>
                <.icon_button
                  href={action[:url]}
                  method={action[:method]}
                  confirm={action[:confirm]}
                  icon_default={action[:icon_default]}
                  icon_hover={action[:icon_hover]}
                  color={action[:color]}
                  title={action[:title] || "Acción"}
                />
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Componente para grilla de articulos
  attr :columns, :string,
    default: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3",
    doc: "Clases para controlar las columnas"

  attr :articles, :list, required: true, doc: "Lista de artículos a mostrar"
  attr :title, :string, default: nil, doc: "Título opcional de la sección"
  attr :subtitle, :string, default: nil, doc: "Subtítulo opcional"
  attr :view_all_url, :string, default: nil, doc: "URL para ver todos los artículos"
  attr :view_all_text, :string, default: "Ver todos", doc: "Texto para el enlace 'ver todos'"

  attr :empty_message, :string,
    default: "No se encontraron artículos",
    doc: "Mensaje cuando no hay artículos"

  attr :empty_text, :string,
    default: "No hay artículos disponibles",
    doc: "Texto descriptivo cuando no hay artículos"

  attr :with_actions, :boolean,
    default: false,
    doc: "Si se deben mostrar acciones administrativas"

  attr :show_border, :boolean, default: true, doc: "Si se debe mostrar borde en el encabezado"

  def article_grid(assigns) do
    assigns = assign_new(assigns, :color_theme, fn -> Config.webpage_theme() end)

    ~H"""
    <section class="mb-8">
      <%= if @title do %>
        <div class={[
          "flex justify-between items-center pb-3 mb-6",
          @show_border && "border-b-2 border-#{@color_theme}-200"
        ]}>
          <div>
            <h2 class={"text-2xl font-bold text-#{@color_theme}-950"}>{@title}</h2>
            <%= if @subtitle do %>
              <p class={"text-sm text-#{@color_theme}-700 mt-1"}>{@subtitle}</p>
            <% end %>
          </div>
          <%= if @view_all_url do %>
            <.link
              href={@view_all_url}
              class={"text-#{@color_theme}-700 hover:text-#{@color_theme}-900 text-sm font-medium flex items-center"}
            >
              {@view_all_text}
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-4 w-4 ml-1"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fill-rule="evenodd"
                  d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z"
                  clip-rule="evenodd"
                />
              </svg>
            </.link>
          <% end %>
        </div>
      <% end %>

      <%= if Enum.empty?(@articles) do %>
        <div class={"bg-#{@color_theme}-50 border border-#{@color_theme}-200 text-#{@color_theme}-800 rounded-md p-6 text-center"}>
          <.icon name="hero-face-frown" class={"mx-auto h-12 w-12 text-#{@color_theme}-400 mb-4"} />
          <h3 class="text-lg font-semibold mb-2">{@empty_message}</h3>
          <p class={"text-#{@color_theme}-700"}>
            {@empty_text}
          </p>
        </div>
      <% else %>
        <div class={"grid gap-6 #{@columns}"}>
          <%= for article <- @articles do %>
            <.article_card
              title={article.title}
              date={article.date}
              image={article.image}
              image_alt={article.title}
              excerpt={article.excerpt}
              url={article.url}
              category={article.category}
              author={article[:author]}
              featured={article[:featured]}
              id={article[:id]}
              actions={
                if @with_actions do
                  [
                    %{
                      url: "/articles/#{article.id}/edit",
                      icon_default: "hero-pencil-square",
                      icon_hover: "hero-pencil-square-solid",
                      color: @color_theme,
                      title: "Editar artículo"
                    },
                    %{
                      url: "/articles/#{article.id}/toggle_featured",
                      icon_default: "hero-star",
                      icon_hover: "hero-star-solid",
                      color: @color_theme,
                      method: :put,
                      title: "Destacar de la semana"
                    },
                    %{
                      url: "/articles/#{article.id}",
                      method: :delete,
                      confirm: "¿Estás seguro de eliminar este artículo?",
                      icon_default: "hero-trash",
                      icon_hover: "hero-trash-solid",
                      color: @color_theme,
                      title: "Eliminar artículo"
                    }
                  ]
                else
                  []
                end
              }
            />
          <% end %>
        </div>
      <% end %>
    </section>
    """
  end

  # Componente para botones de iconos con tooltip
  attr :href, :string, required: true, doc: "URL del enlace"
  attr :method, :string, default: nil, doc: "Método HTTP para el enlace (delete, put, etc.)"
  attr :confirm, :string, default: nil, doc: "Mensaje de confirmación"
  attr :icon_default, :string, required: true, doc: "Nombre del icono por defecto"

  attr :icon_hover, :string,
    default: nil,
    doc: "Nombre del icono al pasar el mouse (si es nil, usa el mismo)"

  attr :color, :string, default: "blue", doc: "Color del icono (blue, red, green, yellow, etc.)"
  attr :title, :string, required: true, doc: "Texto del tooltip"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"
  attr :disabled, :boolean, default: false, doc: "Si el botón está deshabilitado"
  attr :rest, :global, doc: "Atributos adicionales para el elemento"

  def icon_button(assigns) do
    assigns =
      assigns
      |> assign_new(:icon_hover, fn -> assigns.icon_default end)

    ~H"""
    <div
      x-data="{ isHovered: false, showTooltip: false }"
      @mouseenter="isHovered = true; showTooltip = true"
      @mouseleave="isHovered = false; showTooltip = false"
      class="relative inline-block"
    >
      <.link
        href={@href}
        method={@method}
        data-confirm={@confirm}
        class={"p-1.5 text-#{@color}-500 hover:text-#{@color}-700 transition-colors duration-200 flex items-center justify-center rounded-full hover:bg-#{@color}-50 #{@class} #{if @disabled, do: "opacity-50 cursor-not-allowed", else: ""}"}
        {@rest}
      >
        <div class="relative w-5 h-5">
          <div
            x-show="!isHovered"
            x-transition.duration.100ms
            class="absolute inset-0 flex items-center justify-center"
          >
            <.icon name={@icon_default} class="h-5 w-5" />
          </div>
          <div
            x-show="isHovered"
            x-transition.duration.100ms
            class="absolute inset-0 flex items-center justify-center"
          >
            <.icon name={@icon_hover} class="h-5 w-5" />
          </div>
        </div>
      </.link>
      
    <!-- Tooltip - Posicionado con fixed para evitar problemas de overflow -->
      <div
        x-cloak
        x-show="showTooltip"
        x-transition:enter="transition ease-out duration-200"
        x-transition:enter-start="opacity-0 transform scale-95"
        x-transition:enter-end="opacity-100 transform scale-100"
        x-transition:leave="transition ease-in duration-150"
        x-transition:leave-start="opacity-100 transform scale-100"
        x-transition:leave-end="opacity-0 transform scale-95"
        class={"fixed z-50 px-2 py-1 text-xs font-medium text-white bg-#{@color}-700 rounded shadow-sm whitespace-nowrap pointer-events-none mb-1"}
        role="tooltip"
        style="display: none;"
        x-init="$nextTick(() => {
          $watch('showTooltip', value => {
            if (value) {
              const rect = $root.getBoundingClientRect();
              const tooltipWidth = $el.offsetWidth;
              const viewportWidth = window.innerWidth;

              // Calcular posición base perfectamente centrada sobre el icono
              // El icono tiene 20px de ancho y está centrado en el botón
              // Obtenemos el centro exacto del botón
              const buttonCenter = rect.left + (rect.width / 2);

              // Ajustamos para centrar exactamente sobre el icono
              let leftPos = buttonCenter - (tooltipWidth / 2);

              // Aplicamos un pequeño ajuste para compensar cualquier desplazamiento visual
              // Este valor puede necesitar ajustes según el diseño específico
              leftPos = leftPos - 40;  // Ajuste extremadamente agresivo para centrar perfectamente

              // Ajustar si se sale por la derecha
              if (leftPos + tooltipWidth > viewportWidth - 10) {
                leftPos = viewportWidth - tooltipWidth - 10;

                // Asegurar que la flecha apunte al centro del botón
                const arrowEl = $el.querySelector('div');
                if (arrowEl) {
                  // Usamos la misma referencia de buttonCenter que ya calculamos
                  const tooltipLeft = leftPos;
                  const newArrowLeft = buttonCenter - tooltipLeft;
                  const maxArrowLeft = tooltipWidth - 10; // Evitar que la flecha se salga del tooltip
                  arrowEl.style.left = `${Math.min(Math.max(newArrowLeft, 10), maxArrowLeft)}px`;
                  arrowEl.style.transform = 'translateX(-50%)';
                }
              }

              // Ajustar si se sale por la izquierda
              if (leftPos < 10) {
                leftPos = 10;

                // Asegurar que la flecha apunte al centro del botón
                const arrowEl = $el.querySelector('div');
                if (arrowEl) {
                  // Usamos la misma referencia de buttonCenter que ya calculamos
                  const tooltipLeft = leftPos;
                  const newArrowLeft = buttonCenter - tooltipLeft;
                  const maxArrowLeft = tooltipWidth - 10; // Evitar que la flecha se salga del tooltip
                  arrowEl.style.left = `${Math.min(Math.max(newArrowLeft, 10), maxArrowLeft)}px`;
                  arrowEl.style.transform = 'translateX(-50%)';
                }
              }

              $el.style.left = `${leftPos}px`;
              $el.style.top = `${rect.top - $el.offsetHeight - 20}px`;  // Subimos 4px más
              $el.style.display = 'block';
            } else {
              $el.style.display = 'none';
            }
          });
        })"
      >
        {@title}
        <!-- Flecha del tooltip -->
        <div
          class={"absolute top-full left-1/2 transform -translate-x-1/2 border-4 border-transparent border-t-#{@color}-700"}
          style="pointer-events: none;"
        />
      </div>
    </div>
    """
  end

  # Componente para tarjetas de categorías
  attr :name, :string, required: true, doc: "Nombre de la categoría"
  attr :slug, :string, required: true, doc: "Slug de la categoría"
  attr :description, :string, default: nil, doc: "Descripción de la categoría"
  attr :id, :integer, default: nil, doc: "ID de la categoría para acciones"
  attr :article_count, :integer, default: 0, doc: "Número de artículos en la categoría"

  attr :with_actions, :boolean,
    default: false,
    doc: "Si se deben mostrar acciones administrativas"

  attr :color_theme, :string, default: nil, doc: "Tema de color para la tarjeta"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  def category_card(assigns) do
    assigns =
      assigns
      |> assign_new(:color_theme, fn -> Config.webpage_theme() end)

    ~H"""
    <div class={"bg-white rounded-lg shadow-sm border border-gray-200 hover:shadow-md transition-shadow duration-300 overflow-hidden flex flex-col h-full group #{@class}"}>
      <!-- Cabecera de la tarjeta -->
      <div class="bg-gradient-to-r from-blue-600 to-blue-700 p-4 flex items-center justify-between">
        <div class="flex items-center space-x-3 max-w-[75%]">
          <div class="bg-white/20 p-2 rounded-full flex-shrink-0">
            <.icon name="hero-folder" class="h-5 w-5 text-white" />
          </div>
          <h3 class="text-lg font-semibold text-white truncate">{@name}</h3>
        </div>
        <div class="flex items-center space-x-1">
          <.link
            href={"/articles?category=#{@slug}"}
            class="p-1.5 text-white hover:text-white/90 transition-colors duration-200 flex items-center justify-center rounded-full hover:bg-white/20"
            aria-label="Ver artículos de esta categoría"
          >
            <.icon name="hero-eye" class="h-5 w-5" />
          </.link>
        </div>
      </div>
      
    <!-- Contenido de la tarjeta -->
      <div class="p-4 flex-grow">
        <!-- Slug -->
        <div class="mb-4">
          <div class="text-xs text-gray-500 mb-1">Slug:</div>
          <code class="bg-gray-100 px-2 py-1 rounded text-sm font-mono block w-full overflow-x-auto">
            {@slug}
          </code>
        </div>
        
    <!-- Descripción -->
        <div class="mb-4">
          <div class="text-xs text-gray-500 mb-1">Descripción:</div>
          <div class="text-gray-700 text-sm min-h-[60px] max-h-[80px] overflow-y-auto">
            <%= if @description && String.trim(@description) != "" do %>
              {@description}
            <% else %>
              <span class="text-gray-400 italic">Sin descripción</span>
            <% end %>
          </div>
        </div>
      </div>
      
    <!-- Pie de la tarjeta con acciones -->
      <div class="border-t border-gray-100 p-4 bg-gray-50 flex justify-between items-center">
        <!-- Contador de artículos -->
        <div class="flex items-center text-gray-600">
          <.icon name="hero-document-text" class="h-4 w-4 mr-1" />
          <span class="text-sm font-medium">
            {@article_count} artículo{if @article_count != 1, do: "s"}
          </span>
        </div>

        <%= if @with_actions do %>
          <div class="flex items-center space-x-1">
            <.icon_button
              href={"/categories/#{@id}/edit"}
              icon_default="hero-pencil-square"
              icon_hover="hero-pencil-square-solid"
              color="blue"
              title="Editar categoría"
            />
            <.icon_button
              href={"/categories/#{@id}"}
              method="delete"
              confirm="¿Está seguro de que desea eliminar esta categoría? Esta acción no se puede deshacer."
              icon_default="hero-trash"
              icon_hover="hero-trash-solid"
              color="red"
              title="Eliminar categoría"
            />
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Componente para grilla de categorías
  attr :columns, :string,
    default: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3",
    doc: "Clases para controlar las columnas"

  attr :categories, :list, required: true, doc: "Lista de categorías a mostrar"
  attr :title, :string, default: nil, doc: "Título opcional de la sección"
  attr :subtitle, :string, default: nil, doc: "Subtítulo opcional"
  attr :view_all_url, :string, default: nil, doc: "URL para ver todas las categorías"
  attr :view_all_text, :string, default: "Ver todas", doc: "Texto para el enlace 'ver todas'"

  attr :empty_message, :string,
    default: "No se encontraron categorías",
    doc: "Mensaje cuando no hay categorías"

  attr :empty_text, :string,
    default: "No hay categorías disponibles",
    doc: "Texto descriptivo cuando no hay categorías"

  attr :with_actions, :boolean,
    default: false,
    doc: "Si se deben mostrar acciones administrativas"

  attr :show_border, :boolean, default: true, doc: "Si se debe mostrar borde en el encabezado"

  def category_grid(assigns) do
    assigns = assign_new(assigns, :color_theme, fn -> Config.webpage_theme() end)

    ~H"""
    <section class="mb-8">
      <%= if @title do %>
        <div class={[
          "flex justify-between items-center pb-3 mb-6",
          @show_border && "border-b-2 border-#{@color_theme}-200"
        ]}>
          <div>
            <h2 class={"text-2xl font-bold text-#{@color_theme}-950"}>{@title}</h2>
            <%= if @subtitle do %>
              <p class={"text-sm text-#{@color_theme}-700 mt-1"}>{@subtitle}</p>
            <% end %>
          </div>
          <%= if @view_all_url do %>
            <.link
              href={@view_all_url}
              class={"text-#{@color_theme}-700 hover:text-#{@color_theme}-900 text-sm font-medium flex items-center"}
            >
              {@view_all_text}
              <.icon name="hero-arrow-right" class="h-4 w-4 ml-1" />
            </.link>
          <% end %>
        </div>
      <% end %>

      <%= if Enum.empty?(@categories) do %>
        <.empty_state
          message={@empty_message}
          description={@empty_text}
          icon="hero-folder-open"
          color_theme={@color_theme}
        />
      <% else %>
        <div class={"grid gap-6 #{@columns}"}>
          <%= for category <- @categories do %>
            <.category_card
              name={category.name}
              slug={category.slug}
              description={category.description}
              id={category.id}
              with_actions={@with_actions}
              article_count={length(category.articles || [])}
            />
          <% end %>
        </div>
      <% end %>
    </section>
    """
  end

  # Componente para tarjetas de servicios
  attr :title, :string, required: true, doc: "Título del servicio"
  attr :description, :string, required: true, doc: "Descripción del servicio"
  attr :url, :string, required: true, doc: "URL del servicio"
  attr :icon, :string, default: "doc", doc: "Tipo de ícono (doc, clock, alert, etc.)"
  attr :action_text, :string, default: "Ver servicio", doc: "Texto del botón de acción"

  def service_card(assigns) do
    assigns =
      assigns
      |> assign(:color_theme, Config.webpage_theme())

    ~H"""
    <div class={"bg-gradient-to-br from-#{@color_theme}-800 to-#{@color_theme}-950 text-white rounded-lg overflow-hidden shadow-lg group hover:shadow-xl transition-all duration-300"}>
      <div class="p-6">
        <div class="w-12 h-12 bg-white/20 rounded-lg flex items-center justify-center mb-4 group-hover:bg-white/30 transition-colors duration-300">
          <%= case @icon do %>
            <% "doc" -> %>
              <.icon name="hero-document-text" class="h-6 w-6" />
            <% "clock" -> %>
              <.icon name="hero-clock" class="h-6 w-6" />
            <% "alert" -> %>
              <.icon name="hero-exclamation-triangle" class="h-6 w-6" />
            <% "card" -> %>
              <.icon name="hero-credit-card" class="h-6 w-6" />
            <% "shield" -> %>
              <.icon name="hero-shield-check" class="h-6 w-6" />
            <% _ -> %>
              <.icon name="hero-bolt" class="h-6 w-6" />
          <% end %>
        </div>
        <h3 class="text-xl font-bold mb-2">{@title}</h3>
        <p class={"mb-4 text-#{@color_theme}-100"}>
          {@description}
        </p>
        <a
          href={@url}
          class={"inline-flex items-center text-sm font-semibold text-white hover:text-#{@color_theme}-200 transition-colors"}
        >
          {@action_text}
          <.icon name="hero-arrow-right" class="h-4 w-4 ml-1" />
        </a>
      </div>
    </div>
    """
  end

  # Componente para servicios destacados
  attr :title, :string, default: "Servicios Destacados", doc: "Título de la sección"
  attr :services, :list, required: true, doc: "Lista de servicios a mostrar"
  attr :max_services, :integer, default: 2, doc: "Número máximo de servicios a mostrar"

  attr :grid_columns, :string,
    default: "grid-cols-1 md:grid-cols-2",
    doc: "Configuración de columnas del grid"

  def featured_services(assigns) do
    # Limitar los servicios al máximo definido
    assigns =
      assigns
      |> assign(:services, Enum.slice(assigns.services, 0, assigns.max_services))
      |> assign(:color_theme, Config.webpage_theme())

    ~H"""
    <section class="mb-8">
      <div class={"flex justify-between items-center border-b-2 border-#{@color_theme}-200 pb-3 mb-6"}>
        <h2 class={"text-2xl font-bold text-#{@color_theme}-950"}>{@title}</h2>
      </div>

      <div class={"grid gap-6 #{@grid_columns}"}>
        <%= for service <- @services do %>
          <.service_card
            title={service.title}
            description={service.description}
            url={service.url}
            icon={service.icon}
            action_text={service.action_text}
          />
        <% end %>
      </div>
    </section>
    """
  end

  # Banner de notificaciones o anuncios importantes
  attr :message, :string, required: true, doc: "Mensaje principal"
  attr :type, :string, default: "info", doc: "Tipo de alerta: info, warning, success, error"
  attr :dismissible, :boolean, default: true, doc: "Si se puede descartar el banner"
  attr :action_text, :string, default: nil, doc: "Texto del botón de acción (opcional)"
  attr :action_url, :string, default: "#", doc: "URL del botón de acción"

  def alert_banner(assigns) do
    colors = %{
      "info" => "bg-blue-100 text-blue-800 border-blue-200",
      "warning" => "bg-yellow-100 text-yellow-800 border-yellow-200",
      "success" => "bg-green-100 text-green-800 border-green-200",
      "error" => "bg-red-100 text-red-800 border-red-200"
    }

    assigns =
      assigns
      |> assign(color_classes: Map.get(colors, assigns.type, colors["info"]))
      |> assign(assigns, color_theme: Config.webpage_theme())

    ~H"""
    <div
      x-data="{ show: true }"
      x-show="show"
      x-transition:enter="transition ease-out duration-300"
      x-transition:enter-start="opacity-0 transform -translate-y-2"
      x-transition:enter-end="opacity-100 transform translate-y-0"
      x-transition:leave="transition ease-in duration-300"
      x-transition:leave-start="opacity-100 transform translate-y-0"
      x-transition:leave-end="opacity-0 transform -translate-y-2"
      class={"rounded-lg p-4 shadow-sm border mb-6 flex items-center justify-between #{@color_classes}"}
    >
      <div class="flex items-center">
        <%= case @type do %>
          <% "info" -> %>
            <.icon name="hero-information-circle-solid" class="h-5 w-5 mr-3" />
          <% "warning" -> %>
            <.icon name="hero-exclamation-triangle-solid" class="h-5 w-5 mr-3" />
          <% "success" -> %>
            <.icon name="hero-check-circle-solid" class="h-5 w-5 mr-3" />
          <% "error" -> %>
            <.icon name="hero-x-circle-solid" class="h-5 w-5 mr-3" />
        <% end %>
        <p class="text-sm font-medium">{@message}</p>
      </div>
      <div class="flex items-center ml-4">
        <%= if @action_text do %>
          <a href={@action_url} class="text-sm font-semibold mr-4 hover:underline">
            {@action_text}
          </a>
        <% end %>

        <%= if @dismissible do %>
          <button
            @click="show = false"
            class="text-sm font-medium focus:outline-none hover:opacity-75"
            aria-label="Cerrar"
          >
            <.icon name="hero-x-mark-solid" class="h-4 w-4" />
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  # Componente para crear etiquetas de badge
  attr :text, :string, required: true, doc: "Texto a mostrar en la etiqueta"

  attr :color, :string, doc: "Color base de la etiqueta (blue, green, red, yellow, etc.)"

  attr :size, :string, default: "md", doc: "Tamaño de la etiqueta (sm, md, lg)"
  attr :href, :string, default: nil, doc: "URL opcional para hacer la etiqueta clickeable"

  def badge(assigns) do
    # Mapeo de colores para el gradiente y texto
    colors = %{
      "blue" => "from-blue-700 to-blue-900 text-white",
      "green" => "from-green-600 to-green-800 text-white",
      "red" => "from-red-600 to-red-800 text-white",
      "yellow" => "from-yellow-500 to-yellow-700 text-white",
      "purple" => "from-purple-600 to-purple-800 text-white",
      "indigo" => "from-indigo-600 to-indigo-800 text-white",
      "gray" => "from-gray-600 to-gray-800 text-white"
    }

    # Mapeo de tamaños
    sizes = %{
      "sm" => "text-xs px-2 py-0.5",
      "md" => "text-sm px-3 py-1",
      "lg" => "text-base px-4 py-1.5"
    }

    # Obtener las clases según el color y tamaño
    color_classes = Map.get(colors, Config.webpage_theme(), colors["blue"])
    size_classes = Map.get(sizes, assigns.size, sizes["md"])

    assigns =
      assign(assigns,
        color_classes: color_classes,
        size_classes: size_classes
      )

    ~H"""
    <%= if @href do %>
      <a
        href={@href}
        class={"inline-block font-medium rounded bg-gradient-to-br shadow-sm hover:shadow transition-all duration-200 #{@color_classes} #{@size_classes}"}
      >
        {@text}
      </a>
    <% else %>
      <span class={"inline-block font-medium rounded bg-gradient-to-br shadow-sm #{@color_classes} #{@size_classes}"}>
        {@text}
      </span>
    <% end %>
    """
  end

  # Componente de botón principal estilizado
  attr :type, :string, default: "button", doc: "Tipo de botón (button, submit, reset)"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  attr :color, :string,
    default: nil,
    doc: "Color del botón (si no se especifica, usa el tema de la web)"

  attr :icon, :string, default: nil, doc: "Nombre del ícono (opcional)"

  attr :icon_position, :string,
    default: "left",
    values: ["left", "right"],
    doc: "Posición del ícono"

  attr :size, :string,
    default: "md",
    values: ["sm", "md", "lg"],
    doc: "Tamaño del botón"

  attr :disabled, :boolean, default: false, doc: "Si el botón está deshabilitado"
  attr :rest, :global, doc: "Atributos adicionales para el elemento button"
  slot :inner_block, required: true, doc: "Contenido del botón"

  def app_button(assigns) do
    assigns = assign_new(assigns, :color_theme, fn -> Config.webpage_theme() end)

    theme = assigns.color_theme

    # Mapeo de tamaños - ASEGURAR QUE SEAN EXACTAMENTE IGUALES A app_button_secondary
    size_classes = %{
      # Agregamos h-9 para forzar altura específica
      "sm" => "py-1.5 px-4 text-sm h-9",
      "md" => "py-2.5 px-6 text-base h-11",
      "lg" => "py-3 px-8 text-lg h-14"
    }

    assigns =
      assigns
      |> assign(:size_class, Map.get(size_classes, assigns.size, size_classes["md"]))
      |> assign_new(:button_color, fn ->
        case assigns.color do
          nil -> "#{theme}-700 hover:bg-#{theme}-800"
          "primary" -> "#{theme}-700 hover:bg-#{theme}-800"
          "secondary" -> "gray-600 hover:bg-gray-700"
          "success" -> "green-600 hover:bg-green-700"
          "danger" -> "red-600 hover:bg-red-700"
          "warning" -> "yellow-600 hover:bg-yellow-700"
          custom -> custom
        end
      end)

    ~H"""
    <button
      type={@type}
      class={"flex items-center justify-center bg-#{@button_color} text-white font-medium rounded-md shadow-md hover:shadow-lg transition-colors duration-200 #{@size_class} #{if @disabled, do: "opacity-50 cursor-not-allowed", else: ""} #{@class}"}
      disabled={@disabled}
      {@rest}
    >
      <%= if @icon && @icon_position == "left" do %>
        <.icon name={@icon} class="h-5 w-5 mr-1.5" />
      <% end %>
      {render_slot(@inner_block)}
      <%= if @icon && @icon_position == "right" do %>
        <.icon name={@icon} class="h-5 w-5 ml-1.5" />
      <% end %>
    </button>
    """
  end

  # Componente de botón secundario (outline)
  # Componente de botón secundario (outline)
  attr :type, :string, default: "button", doc: "Tipo de botón (button, submit, reset)"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  attr :color, :string,
    default: nil,
    doc: "Color del botón (si no se especifica, usa el tema de la web)"

  attr :icon, :string, default: nil, doc: "Nombre del ícono (opcional)"

  attr :icon_position, :string,
    default: "left",
    values: ["left", "right"],
    doc: "Posición del ícono"

  attr :size, :string,
    default: "md",
    values: ["sm", "md", "lg"],
    doc: "Tamaño del botón"

  attr :disabled, :boolean, default: false, doc: "Si el botón está deshabilitado"
  attr :rest, :global, doc: "Atributos adicionales para el elemento button o a"

  attr :navigate, :string,
    default: nil,
    doc: "URL para navegación (convierte el botón en un enlace)"

  slot :inner_block, required: true, doc: "Contenido del botón"

  def app_button_secondary(assigns) do
    assigns = assign_new(assigns, :color_theme, fn -> Config.webpage_theme() end)

    theme = assigns.color_theme

    size_classes = %{
      # Misma altura forzada
      "sm" => "py-1.5 px-4 text-sm h-9",
      "md" => "py-2.5 px-6 text-base h-11",
      "lg" => "py-3 px-8 text-lg h-14"
    }

    assigns =
      assigns
      |> assign(:size_class, Map.get(size_classes, assigns.size, size_classes["md"]))
      |> assign_new(:text_color, fn ->
        case assigns.color do
          nil -> "#{theme}-700"
          "primary" -> "#{theme}-700"
          "secondary" -> "gray-700"
          "success" -> "green-700"
          "danger" -> "red-700"
          "warning" -> "yellow-700"
          custom -> custom
        end
      end)
      |> assign_new(:border_color, fn ->
        case assigns.color do
          nil -> "#{theme}-300"
          "primary" -> "#{theme}-300"
          "secondary" -> "gray-300"
          "success" -> "green-300"
          "danger" -> "red-300"
          "warning" -> "yellow-300"
          custom -> custom
        end
      end)
      |> assign_new(:hover_bg, fn ->
        case assigns.color do
          nil -> "#{theme}-50"
          "primary" -> "#{theme}-50"
          "secondary" -> "gray-50"
          "success" -> "green-50"
          "danger" -> "red-50"
          "warning" -> "yellow-50"
          custom -> custom
        end
      end)

    ~H"""
    <%= if @navigate && !@disabled do %>
      <.link
        navigate={@navigate}
        class={"flex items-center justify-center border border-#{@border_color} rounded-md text-#{@text_color} bg-white hover:bg-#{@hover_bg} transition-colors duration-200 font-medium shadow-sm #{@size_class} #{@class}"}
        {@rest}
      >
        <%= if @icon && @icon_position == "left" do %>
          <.icon name={@icon} class="h-5 w-5 mr-1.5" />
        <% end %>
        {render_slot(@inner_block)}
        <%= if @icon && @icon_position == "right" do %>
          <.icon name={@icon} class="h-5 w-5 ml-1.5" />
        <% end %>
      </.link>
    <% else %>
      <button
        type={@type}
        class={"flex items-center justify-center border border-#{@border_color} rounded-md text-#{@text_color} bg-white hover:bg-#{@hover_bg} transition-colors duration-200 font-medium shadow-sm #{@size_class} #{if @disabled, do: "opacity-50 cursor-not-allowed", else: ""} #{@class}"}
        disabled={@disabled}
        {@rest}
      >
        <%= if @icon && @icon_position == "left" do %>
          <.icon name={@icon} class="h-5 w-5 mr-1.5" />
        <% end %>
        {render_slot(@inner_block)}
        <%= if @icon && @icon_position == "right" do %>
          <.icon name={@icon} class="h-5 w-5 ml-1.5" />
        <% end %>
      </button>
    <% end %>
    """
  end

  # Componente de paginación
  attr :page, :integer, required: true, doc: "Página actual"
  attr :total_pages, :integer, required: true, doc: "Número total de páginas"
  attr :route_func, :any, required: true, doc: "Función para generar las rutas de paginación"

  attr :align, :string,
    default: "center",
    values: ["left", "center", "right"],
    doc: "Alineación de la paginación"

  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  def pagination(assigns) do
    assigns =
      assigns
      |> assign(:color_theme, Config.webpage_theme())
      |> assign(:pages_to_show, pages_to_show(assigns.page, assigns.total_pages))

    ~H"""
    <div class={[
      "flex mt-8 mb-4",
      @align == "center" && "justify-center",
      @align == "left" && "justify-start",
      @align == "right" && "justify-end",
      @class
    ]}>
      <nav class="inline-flex rounded-md shadow-sm isolate" aria-label="Paginación">
        <!-- Botón Anterior -->
        <%= if @page > 1 do %>
          <a
            href={@route_func.(@page - 1)}
            class={"relative inline-flex items-center px-4 py-2 text-sm font-medium border border-r-0 border-#{@color_theme}-300 rounded-l-md hover:bg-#{@color_theme}-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-#{@color_theme}-500 focus:border-#{@color_theme}-500"}
          >
            <.icon name="hero-chevron-left-outline" class="w-5 h-5 mr-1" /> Anterior
          </a>
        <% else %>
          <span class="relative inline-flex items-center px-4 py-2 text-sm font-medium border border-r-0 border-gray-300 rounded-l-md text-gray-400 bg-gray-100 cursor-not-allowed">
            <.icon name="hero-chevron-left-outline" class="w-5 h-5 mr-1" /> Anterior
          </span>
        <% end %>
        
    <!-- Números de página -->
        <%= for page_num <- @pages_to_show do %>
          <%= if page_num == :ellipsis do %>
            <span class={"relative inline-flex items-center px-4 py-2 text-sm font-medium border border-r-0 border-#{@color_theme}-300 text-gray-700"}>
              ...
            </span>
          <% else %>
            <a
              href={if page_num == @page, do: "#", else: @route_func.(page_num)}
              class={[
                "relative inline-flex items-center px-4 py-2 text-sm font-medium border border-r-0 border-#{@color_theme}-300",
                page_num == @page && "text-white bg-#{@color_theme}-600 z-10",
                page_num != @page &&
                  "text-gray-700 hover:bg-#{@color_theme}-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-#{@color_theme}-500 focus:border-#{@color_theme}-500"
              ]}
              aria-current={if page_num == @page, do: "page", else: nil}
            >
              {page_num}
            </a>
          <% end %>
        <% end %>
        
    <!-- Botón Siguiente -->
        <%= if @page < @total_pages do %>
          <a
            href={@route_func.(@page + 1)}
            class={"relative inline-flex items-center px-4 py-2 text-sm font-medium border border-#{@color_theme}-300 rounded-r-md hover:bg-#{@color_theme}-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-#{@color_theme}-500 focus:border-#{@color_theme}-500"}
          >
            Siguiente <.icon name="hero-chevron-right-outline" class="w-5 h-5 ml-1" />
          </a>
        <% else %>
          <span class="relative inline-flex items-center px-4 py-2 text-sm font-medium border border-gray-300 rounded-r-md text-gray-400 bg-gray-100 cursor-not-allowed">
            Siguiente <.icon name="hero-chevron-right-outline" class="w-5 h-5 ml-1" />
          </span>
        <% end %>
      </nav>
    </div>
    """
  end

  attr :action, :string, required: true, doc: "URL para enviar la búsqueda"
  attr :search_term, :string, default: "", doc: "Término de búsqueda actual"
  attr :category_options, :list, default: [], doc: "Lista de opciones de categoría"
  attr :current_category, :string, default: "", doc: "Categoría seleccionada actualmente"

  attr :include_category_filter, :boolean,
    default: true,
    doc: "Si se debe incluir el filtro de categorías"

  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  attr :placeholder, :string,
    default: "Buscar por título o contenido...",
    doc: "Texto de placeholder para el campo de búsqueda"

  attr :button_text, :string, default: "Buscar", doc: "Texto del botón de búsqueda"
  attr :compact, :boolean, default: false, doc: "Versión compacta del formulario (para sidebar)"

  attr :professional, :boolean,
    default: true,
    doc: "Versión más discreta y profesional para el formulario completo"

  def search_form(assigns) do
    assigns = assign(assigns, :color_theme, Config.webpage_theme())

    ~H"""
    <form action={@action} method="get" class={"space-y-4 #{@class}"}>
      <%= if !@compact && @include_category_filter do %>
        <%= if @professional do %>
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <!-- Filtro por categoría (versión profesional) -->
            <div class="flex-grow max-w-xs">
              <label for="category" class="block text-sm font-medium text-gray-700 mb-1">
                Filtrar por categoría
              </label>
              <select
                id="category"
                name="category"
                class="w-full border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500"
                onchange="if(this.form) this.form.submit();"
              >
                <option value="">Todas las categorías</option>
                <%= for category <- @category_options do %>
                  <option value={category.slug} selected={@current_category == category.slug}>
                    {category.name}
                  </option>
                <% end %>
              </select>
            </div>
            
    <!-- Buscador (versión profesional) -->
            <div class="flex-grow max-w-md">
              <label for="search" class="block text-sm font-medium text-gray-700 mb-1">
                Buscar artículos
              </label>
              <div class="relative">
                <input
                  type="text"
                  id="search"
                  name="search"
                  value={@search_term}
                  placeholder={@placeholder}
                  class="w-full border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500 pr-10"
                />
                <div class="absolute inset-y-0 right-0 flex items-center pr-3">
                  <.icon name="hero-magnifying-glass-solid" class="h-5 w-5 text-gray-400" />
                </div>
              </div>
            </div>
            
    <!-- Botón de búsqueda (versión profesional) -->
            <div class="flex self-end mb-0.5">
              <button
                type="submit"
                class="bg-blue-700 hover:bg-blue-800 text-white font-medium py-2 px-4 rounded-md transition-colors duration-300"
              >
                {@button_text}
              </button>
            </div>
          </div>
        <% else %>
          <!-- Versión original con fondo azul -->
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <!-- Filtro por categoría -->
            <div class="flex-grow max-w-xs">
              <label for="category" class={"block text-sm font-medium text-#{@color_theme}-700 mb-1"}>
                Filtrar por categoría
              </label>
              <select
                id="category"
                name="category"
                class={"w-full border-gray-300 rounded-md shadow-sm focus:border-#{@color_theme}-500 focus:ring-#{@color_theme}-500"}
                onchange="if(this.form) this.form.submit();"
              >
                <option value="">Todas las categorías</option>
                <%= for category <- @category_options do %>
                  <option value={category.slug} selected={@current_category == category.slug}>
                    {category.name}
                  </option>
                <% end %>
              </select>
            </div>
            
    <!-- Buscador -->
            <div class="flex-grow max-w-md">
              <label for="search" class={"block text-sm font-medium text-#{@color_theme}-700 mb-1"}>
                Buscar artículos
              </label>
              <div class="relative">
                <input
                  type="text"
                  id="search"
                  name="search"
                  value={@search_term}
                  placeholder={@placeholder}
                  class={"w-full border-gray-300 rounded-md shadow-sm focus:border-#{@color_theme}-500 focus:ring-#{@color_theme}-500 pr-10"}
                />
                <div class="absolute inset-y-0 right-0 flex items-center pr-3">
                  <.icon name="hero-magnifying-glass-solid" class="h-5 w-5 text-gray-400" />
                </div>
              </div>
            </div>
            
    <!-- Botón de búsqueda -->
            <div class="flex self-end mb-0.5">
              <button
                type="submit"
                class={"bg-#{@color_theme}-700 hover:bg-#{@color_theme}-800 text-white font-medium py-2 px-4 rounded-md transition-colors duration-300"}
              >
                {@button_text}
              </button>
            </div>
          </div>
        <% end %>
      <% else %>
        <!-- Versión compacta para sidebar -->
        <div class="relative">
          <input
            type="text"
            name="search"
            value={@search_term}
            placeholder={@placeholder}
            class={"w-full border-gray-300 rounded-md shadow-sm focus:border-#{@color_theme}-500 focus:ring-#{@color_theme}-500 pr-10"}
          />
          <button type="submit" class="absolute inset-y-0 right-0 flex items-center pr-3">
            <.icon
              name="hero-magnifying-glass-solid"
              class={"h-5 w-5 text-gray-400 hover:text-#{@color_theme}-500"}
            />
          </button>
        </div>

        <%= if @include_category_filter && @current_category != "" do %>
          <input type="hidden" name="category" value={@current_category} />
        <% end %>
      <% end %>
      
    <!-- Preservar página actual -->
      <input type="hidden" name="page" value="1" />
    </form>
    """
  end

  attr :items, :list, required: true, doc: "Lista de ítems del breadcrumb"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"
  attr :separator_svg, :boolean, default: true, doc: "Usar SVG como separador en lugar de texto"

  def breadcrumb(assigns) do
    assigns = assign_new(assigns, :color_theme, fn -> Config.webpage_theme() end)

    ~H"""
    <nav class={"flex text-sm text-gray-500 #{@class}"} aria-label="Breadcrumb">
      <ol class="inline-flex items-center space-x-1 flex-wrap">
        <%= for {item, index} <- Enum.with_index(@items) do %>
          <li class="flex items-center">
            <%= if index > 0 do %>
              <%= if @separator_svg do %>
                <svg class="flex-shrink-0 w-4 h-4 mx-1" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    fill-rule="evenodd"
                    d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                    clip-rule="evenodd"
                  >
                  </path>
                </svg>
              <% else %>
                <span class="mx-1">/</span>
              <% end %>
            <% end %>

            <%= if item[:href] do %>
              <.link
                navigate={item.href}
                class={"hover:text-#{@color_theme}-700 truncate max-w-[100px] sm:max-w-[150px] md:max-w-[200px] lg:max-w-[250px]"}
              >
                {item.text}
              </.link>
            <% else %>
              <span class={"text-gray-700 truncate max-w-[120px] sm:max-w-[150px] md:max-w-[250px] lg:max-w-[350px] #{if index == length(@items) - 1, do: "font-medium", else: ""}"}>
                {item.text}
              </span>
            <% end %>
          </li>
        <% end %>
      </ol>
    </nav>
    """
  end

  # Función auxiliar para determinar qué páginas mostrar en la paginación
  defp pages_to_show(current_page, total_pages) do
    cond do
      # Menos de 8 páginas - mostrar todas
      total_pages <= 8 ->
        Enum.to_list(1..total_pages)

      # Página actual al inicio
      current_page <= 4 ->
        Enum.to_list(1..5) ++ [:ellipsis, total_pages]

      # Página actual al final
      current_page >= total_pages - 3 ->
        [1, :ellipsis] ++ Enum.to_list((total_pages - 4)..total_pages)

      # Página actual en el medio
      true ->
        [1, :ellipsis] ++
          Enum.to_list((current_page - 1)..(current_page + 1)) ++ [:ellipsis, total_pages]
    end
  end

  attr :id, :string, required: true, doc: "ID único para el modal"
  attr :image_src, :string, required: true, doc: "URL de la imagen"
  attr :image_alt, :string, default: "Imagen", doc: "Texto alternativo para la imagen"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  def image_modal(assigns) do
    ~H"""
    <div
      id={@id}
      x-data="{ open: false }"
      x-show="open"
      x-cloak
      @keydown.escape.window="open = false"
      class={"fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 md:p-12 #{@class}"}
      role="dialog"
      aria-modal="true"
    >
      <div
        class="fixed inset-0 bg-black bg-opacity-80 transition-opacity"
        x-show="open"
        x-transition:enter="transition ease-out duration-300"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="transition ease-in duration-200"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0"
        @click="open = false"
      >
      </div>

      <div
        class="relative max-w-5xl w-full max-h-[90vh] bg-white rounded-lg shadow-2xl overflow-hidden transform"
        x-show="open"
        x-transition:enter="transition ease-out duration-300"
        x-transition:enter-start="opacity-0 scale-95"
        x-transition:enter-end="opacity-100 scale-100"
        x-transition:leave="transition ease-in duration-200"
        x-transition:leave-start="opacity-100 scale-100"
        x-transition:leave-end="opacity-0 scale-95"
        @click.outside="open = false"
      >
        <div class="relative h-full w-full flex items-center justify-center bg-gray-100">
          <img src={@image_src} alt={@image_alt} class="max-h-[80vh] max-w-full object-contain" />
        </div>

        <button
          type="button"
          class="absolute top-3 right-3 text-white bg-black bg-opacity-50 hover:bg-opacity-70 rounded-full p-2 focus:outline-none focus:ring-2 focus:ring-white"
          @click="open = false"
          aria-label="Cerrar"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
      </div>
    </div>
    """
  end

  # Helper para determinar si un enlace está activo
  defp active_class(nil, _link), do: ""
  defp active_class(_current_path, "#"), do: ""

  defp active_class(current_path, link) do
    if current_path == link, do: "bg-#{Config.webpage_theme()}-700 text-white", else: ""
  end
end
