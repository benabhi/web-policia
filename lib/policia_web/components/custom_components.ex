defmodule PoliciaWeb.CustomComponents do
  use Phoenix.Component
  alias Policia.Config
  # alias Policia.Utils

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
            <svg
              class="h-6 w-6"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              aria-hidden="true"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4 6h16M4 12h16M4 18h16"
              />
            </svg>
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
              <svg
                class="h-6 w-6"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                aria-hidden="true"
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
                        <svg
                          class="ml-2 w-4 h-4 fill-current text-white transition-transform duration-300"
                          x-bind:class="open ? 'rotate-180' : ''"
                          xmlns="http://www.w3.org/2000/svg"
                          viewBox="0 0 24 24"
                          aria-hidden="true"
                        >
                          <path d="M12 15l-6-6h12z" />
                        </svg>
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
                                <svg
                                  class={"ml-2 w-4 h-4 fill-current text-#{@color_theme}-300 transition-transform duration-300"}
                                  x-bind:class="subOpen ? 'rotate-180' : ''"
                                  xmlns="http://www.w3.org/2000/svg"
                                  viewBox="0 0 24 24"
                                  aria-hidden="true"
                                >
                                  <path d="M12 15l-6-6h12z" />
                                </svg>
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
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5 mr-2"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
                        />
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                        />
                      </svg>
                      Configuración
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
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          class="h-5 w-5 mr-2"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                          />
                        </svg>
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
                        class="h-5 w-5 mr-1"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"
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
                        class="h-5 w-5 mr-1"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"
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
          
    <!-- Menú principal desktop - MODIFICADO PARA SER MÁS COMPACTO -->
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

                      <svg
                        class={"ml-2 w-4 h-4 fill-current text-white group-hover:text-#{@color_theme}-200 transition-colors duration-300"}
                        xmlns="http://www.w3.org/2000/svg"
                        viewBox="0 0 24 24"
                        aria-hidden="true"
                      >
                        <path d="M12 15l-6-6h12z" />
                      </svg>
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
                              <svg
                                class={"ml-2 w-4 h-4 fill-current text-#{@color_theme}-300 group-hover/submenu:text-white transition-colors duration-300"}
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 24"
                                aria-hidden="true"
                              >
                                <path d="M8 6l8 6-8 6z" />
                              </svg>
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
                  <svg
                    class="w-4 h-4"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M19 9l-7 7-7-7"
                    />
                  </svg>
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
                    <svg
                      class={"w-5 h-5 mr-2 text-#{@color_theme}-700"}
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
                      />
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                    </svg>
                    Configuración
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
                      <svg
                        class={"w-5 h-5 mr-2 text-#{@color_theme}-700"}
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                        />
                      </svg>
                      Cerrar sesión
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
          <div class="relative rounded-lg overflow-hidden shadow-md h-64 md:h-80">
            <img
              src={@image_src}
              alt={@image_alt}
              class="absolute inset-0 w-full h-full object-cover"
            />
            <div class={"absolute inset-0 border-2 border-#{@color_theme}-200 opacity-50 pointer-events-none rounded-lg"}>
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
                  class="h-5 w-5 mr-1"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z" />
                </svg>
                Twitter
              </a>
              <a
                href="#"
                class={"inline-flex items-center text-#{@color_theme}-700 hover:text-#{@color_theme}-900 text-sm font-medium transition-colors duration-200"}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5 mr-1"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M9 8h-3v4h3v12h5v-12h3.642l.358-4h-4v-1.667c0-.955.192-1.333 1.115-1.333h2.885v-5h-3.808c-3.596 0-5.192 1.583-5.192 4.615v3.385z" />
                </svg>
                Facebook
              </a>
              <a
                href="#"
                class={"inline-flex items-center text-#{@color_theme}-700 hover:text-#{@color_theme}-900 text-sm font-medium transition-colors duration-200"}
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5 mr-1"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M7.8,2H16.2C19.4,2 22,4.6 22,7.8V16.2A5.8,5.8 0 0,1 16.2,22H7.8C4.6,22 2,19.4 2,16.2V7.8A5.8,5.8 0 0,1 7.8,2M7.6,4A3.6,3.6 0 0,0 4,7.6V16.4C4,18.39 5.61,20 7.6,20H16.4A3.6,3.6 0 0,0 20,16.4V7.6C20,5.61 18.39,4 16.4,4H7.6M17.25,5.5A1.25,1.25 0 0,1 18.5,6.75A1.25,1.25 0 0,1 17.25,8A1.25,1.25 0 0,1 16,6.75A1.25,1.25 0 0,1 17.25,5.5M12,7A5,5 0 0,1 17,12A5,5 0 0,1 12,17A5,5 0 0,1 7,12A5,5 0 0,1 12,7M12,9A3,3 0 0,0 9,12A3,3 0 0,0 12,15A3,3 0 0,0 15,12A3,3 0 0,0 12,9Z" />
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
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5 mr-1"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" />
                </svg>
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
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class={"h-10 w-10 text-#{@color_theme}-950"}
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M12 2L1 12h3v9h7v-6h2v6h7v-9h3L12 2z" />
                </svg>
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
              <%= for social <- @social_links do %>
                <a
                  href={social.url}
                  target="_blank"
                  aria-label={social.name}
                  class={"bg-#{@color_theme}-900 hover:bg-#{@color_theme}-800 p-2 rounded-full transition-colors duration-200"}
                >
                  <%= case social.icon do %>
                    <% "twitter" -> %>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <path d="M24 4.557c-.883.392-1.832.656-2.828.775 1.017-.609 1.798-1.574 2.165-2.724-.951.564-2.005.974-3.127 1.195-.897-.957-2.178-1.555-3.594-1.555-3.179 0-5.515 2.966-4.797 6.045-4.091-.205-7.719-2.165-10.148-5.144-1.29 2.213-.669 5.108 1.523 6.574-.806-.026-1.566-.247-2.229-.616-.054 2.281 1.581 4.415 3.949 4.89-.693.188-1.452.232-2.224.084.626 1.956 2.444 3.379 4.6 3.419-2.07 1.623-4.678 2.348-7.29 2.04 2.179 1.397 4.768 2.212 7.548 2.212 9.142 0 14.307-7.721 13.995-14.646.962-.695 1.797-1.562 2.457-2.549z" />
                      </svg>
                    <% "facebook" -> %>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <path d="M9 8h-3v4h3v12h5v-12h3.642l.358-4h-4v-1.667c0-.955.192-1.333 1.115-1.333h2.885v-5h-3.808c-3.596 0-5.192 1.583-5.192 4.615v3.385z" />
                      </svg>
                    <% "instagram" -> %>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <path d="M7.8,2H16.2C19.4,2 22,4.6 22,7.8V16.2A5.8,5.8 0 0,1 16.2,22H7.8C4.6,22 2,19.4 2,16.2V7.8A5.8,5.8 0 0,1 7.8,2M7.6,4A3.6,3.6 0 0,0 4,7.6V16.4C4,18.39 5.61,20 7.6,20H16.4A3.6,3.6 0 0,0 20,16.4V7.6C20,5.61 18.39,4 16.4,4H7.6M17.25,5.5A1.25,1.25 0 0,1 18.5,6.75A1.25,1.25 0 0,1 17.25,8A1.25,1.25 0 0,1 16,6.75A1.25,1.25 0 0,1 17.25,5.5M12,7A5,5 0 0,1 17,12A5,5 0 0,1 12,17A5,5 0 0,1 7,12A5,5 0 0,1 12,7M12,9A3,3 0 0,0 9,12A3,3 0 0,0 12,15A3,3 0 0,0 15,12A3,3 0 0,0 12,9Z" />
                      </svg>
                    <% "youtube" -> %>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <path d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0-3.897.266-4.356 2.62-4.385 8.816.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0 3.897-.266 4.356-2.62 4.385-8.816-.029-6.185-.484-8.549-4.385-8.816zm-10.615 12.816v-8l8 3.993-8 4.007z" />
                      </svg>
                    <% _ -> %>
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2zm-1 15h2v-6h-2v6zm0-8h2V7h-2v2z" />
                      </svg>
                  <% end %>
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
                      <%= cond do %>
                        <% link[:icon] == "info" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class={"h-4 w-4 mr-2 text-#{@color_theme}-400"}
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path
                              fill-rule="evenodd"
                              d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2h-1V9a1 1 0 00-1-1H9z"
                              clip-rule="evenodd"
                            />
                          </svg>
                        <% link[:icon] == "phone" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class={"h-4 w-4 mr-2 text-#{@color_theme}-400"}
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
                          </svg>
                        <% link[:icon] == "user" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class={"h-4 w-4 mr-2 text-#{@color_theme}-400"}
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path
                              fill-rule="evenodd"
                              d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-6-3a2 2 0 11-4 0 2 2 0 014 0zm-2 4a5 5 0 00-4.546 2.916A5.986 5.986 0 0010 16a5.986 5.986 0 004.546-2.084A5 5 0 0010 11z"
                              clip-rule="evenodd"
                            />
                          </svg>
                        <% link[:icon] == "news" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class={"h-4 w-4 mr-2 text-#{@color_theme}-400"}
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path
                              fill-rule="evenodd"
                              d="M5 4a3 3 0 00-3 3v6a3 3 0 003 3h10a3 3 0 003-3V7a3 3 0 00-3-3H5zm-1 9v-1h5v2H5a1 1 0 01-1-1zm7 1h4a1 1 0 001-1v-1h-5v2zm0-4h5V8h-5v2zM9 8H4v2h5V8z"
                              clip-rule="evenodd"
                            />
                          </svg>
                        <% link[:icon] == "calendar" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class={"h-4 w-4 mr-2 text-#{@color_theme}-400"}
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path
                              fill-rule="evenodd"
                              d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"
                              clip-rule="evenodd"
                            />
                          </svg>
                        <% true -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class={"h-4 w-4 mr-2 text-#{@color_theme}-400"}
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path
                              fill-rule="evenodd"
                              d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z"
                              clip-rule="evenodd"
                            />
                          </svg>
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
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class={"h-5 w-5 mr-3 text-#{@color_theme}-400 mt-1 flex-shrink-0"}
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z"
                clip-rule="evenodd"
              />
            </svg>
            <div>
              <h4 class={"text-#{@color_theme}-200 font-semibold mb-1"}>Dirección</h4>
              <p class="text-sm text-gray-300">{@address}</p>
            </div>
          </div>

          <div class="flex items-start">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class={"h-5 w-5 mr-3 text-#{@color_theme}-400 mt-1 flex-shrink-0"}
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
            </svg>
            <div>
              <h4 class={"text-#{@color_theme}-200 font-semibold mb-1"}>Teléfono</h4>
              <p class="text-sm text-gray-300">{@phone}</p>
            </div>
          </div>

          <div class="flex items-start">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class={"h-5 w-5 mr-3 text-#{@color_theme}-400 mt-1 flex-shrink-0"}
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
              <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
            </svg>
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
          class="h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
      </button>
      <button
        @click="current = (current + 1) % totalSlides"
        class={"absolute right-4 top-1/2 transform -translate-y-1/2 bg-#{@color_theme}-800/70 hover:bg-#{@color_theme}-700 text-white w-10 h-10 rounded-full flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-#{@color_theme}-500 focus:ring-opacity-50 transition-all duration-200"}
        aria-label="Imagen siguiente"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
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
  slot :inner_block, required: true, doc: "Contenido de la barra lateral"

  def sidebar_box(assigns) do
    assigns =
      assigns
      |> assign(
        :color_theme,
        Config.webpage_theme()
      )

    ~H"""
    <div class={"bg-white rounded-lg shadow-md border border-#{@color_theme}-100 overflow-hidden"}>
      <div class={"bg-#{@color_theme}-900 text-white p-4"}>
        <h2 class="font-semibold text-lg">{@title}</h2>
      </div>
      <div class="p-4">
        {render_slot(@inner_block)}
      </div>
    </div>
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
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2h-1V9a1 1 0 00-1-1H9z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  <% "doc" -> %>
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4zm2 6a1 1 0 011-1h6a1 1 0 110 2H7a1 1 0 01-1-1zm1 3a1 1 0 100 2h6a1 1 0 100-2H7z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  <% "calendar" -> %>
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  <% "alert" -> %>
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  <% _ -> %>
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z"
                        clip-rule="evenodd"
                      />
                    </svg>
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
  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  def article_card(assigns) do
    assigns =
      assigns
      |> assign_new(:color_theme, fn -> Config.webpage_theme() end)
      |> assign_new(:image_alt, fn -> assigns[:title] end)

    ~H"""
    <div class={"bg-white rounded-lg overflow-hidden shadow-md hover:shadow-lg transition-shadow duration-300 border border-#{@color_theme}-100 flex flex-col h-full group #{@class}"}>
      <%= if @image do %>
        <div class="relative h-48 overflow-hidden">
          <img
            src={@image}
            alt={@image_alt}
            class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
          />
          <%= if @category do %>
            <div class="absolute top-2 right-2">
              <.badge text={@category} color={@color_theme} size="sm" />
            </div>
          <% end %>

          <%= if Enum.any?(@actions) do %>
            <div class="absolute bottom-0 right-0 flex space-x-1 p-2 opacity-0 group-hover:opacity-100 transition-opacity">
              <%= for action <- @actions do %>
                <.link
                  href={action.url}
                  method={Map.get(action, :method)}
                  data-confirm={Map.get(action, :confirm)}
                >
                  <span class={"bg-#{action.color || @color_theme}-600 text-white p-2 rounded-md hover:bg-#{action.color || @color_theme}-700 transition-all flex items-center justify-center"}>
                    <%= if action.icon do %>
                      <.button_icon name={action.icon} />
                    <% else %>
                      <span>{action.text}</span>
                    <% end %>
                  </span>
                </.link>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>

      <div class="p-4 flex-grow">
        <div class={"text-sm text-#{@color_theme}-700 mb-2"}>{@date}</div>
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

        <.link
          href={@url}
          class={"inline-flex items-center text-sm font-semibold text-#{@color_theme}-700 hover:text-#{@color_theme}-900"}
        >
          Leer más
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4 ml-1"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M14 5l7 7m0 0l-7 7m7-7H3"
            />
          </svg>
        </.link>
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
          <svg
            class={"mx-auto h-12 w-12 text-#{@color_theme}-400 mb-4"}
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
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
              actions={
                if @with_actions do
                  [
                    %{
                      url: "/articles/#{article.id}/edit",
                      icon: "edit",
                      color: @color_theme
                    },
                    %{
                      url: "/articles/#{article.id}",
                      method: :delete,
                      confirm: "¿Estás seguro de eliminar este artículo?",
                      icon: "close",
                      color: "red"
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
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
            <% "clock" -> %>
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
                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            <% "alert" -> %>
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
                  d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                />
              </svg>
            <% "card" -> %>
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
                  d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"
                />
              </svg>
            <% "shield" -> %>
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
                  d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                />
              </svg>
            <% _ -> %>
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
                  d="M13 10V3L4 14h7v7l9-11h-7z"
                />
              </svg>
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
            <svg class="h-5 w-5 mr-3" viewBox="0 0 20 20" fill="currentColor">
              <path
                fill-rule="evenodd"
                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2h-1V9a1 1 0 00-1-1H9z"
                clip-rule="evenodd"
              />
            </svg>
          <% "warning" -> %>
            <svg class="h-5 w-5 mr-3" viewBox="0 0 20 20" fill="currentColor">
              <path
                fill-rule="evenodd"
                d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                clip-rule="evenodd"
              />
            </svg>
          <% "success" -> %>
            <svg class="h-5 w-5 mr-3" viewBox="0 0 20 20" fill="currentColor">
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              />
            </svg>
          <% "error" -> %>
            <svg class="h-5 w-5 mr-3" viewBox="0 0 20 20" fill="currentColor">
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
                clip-rule="evenodd"
              />
            </svg>
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
            <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
              <path
                fill-rule="evenodd"
                d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                clip-rule="evenodd"
              />
            </svg>
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
        <.button_icon name={@icon} class="mr-1.5" />
      <% end %>
      {render_slot(@inner_block)}
      <%= if @icon && @icon_position == "right" do %>
        <.button_icon name={@icon} class="ml-1.5" />
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

    # Mapeo de tamaños - DEBEN SER EXACTAMENTE IGUALES A app_button
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
          <.button_icon name={@icon} class="mr-1.5" />
        <% end %>
        {render_slot(@inner_block)}
        <%= if @icon && @icon_position == "right" do %>
          <.button_icon name={@icon} class="ml-1.5" />
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
          <.button_icon name={@icon} class="mr-1.5" />
        <% end %>
        {render_slot(@inner_block)}
        <%= if @icon && @icon_position == "right" do %>
          <.button_icon name={@icon} class="ml-1.5" />
        <% end %>
      </button>
    <% end %>
    """
  end

  # Componente auxiliar para los íconos de botones
  attr :name, :string, required: true, doc: "Nombre del ícono"
  attr :class, :string, default: "", doc: "Clases CSS adicionales"

  def button_icon(assigns) do
    ~H"""
    <%= case @name do %>
      <% "check" -> %>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={"h-5 w-5 #{@class}"}
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path
            fill-rule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
            clip-rule="evenodd"
          />
        </svg>
      <% "back" -> %>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={"h-5 w-5 #{@class}"}
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path
            fill-rule="evenodd"
            d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z"
            clip-rule="evenodd"
          />
        </svg>
      <% "save" -> %>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={"h-5 w-5 #{@class}"}
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path d="M7.707 10.293a1 1 0 10-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L11 11.586V6h5a2 2 0 012 2v7a2 2 0 01-2 2H4a2 2 0 01-2-2V8a2 2 0 012-2h5v5.586l-1.293-1.293zM9 4a1 1 0 012 0v2H9V4z" />
        </svg>
      <% "close" -> %>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={"h-5 w-5 #{@class}"}
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path
            fill-rule="evenodd"
            d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
            clip-rule="evenodd"
          />
        </svg>
      <% "edit" -> %>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={"h-5 w-5 #{@class}"}
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
        </svg>
      <% "add" -> %>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={"h-5 w-5 #{@class}"}
          viewBox="0 0 20 20"
          fill="currentColor"
        >
          <path
            fill-rule="evenodd"
            d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"
            clip-rule="evenodd"
          />
        </svg>
      <% _ -> %>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={"h-5 w-5 #{@class}"}
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M14 5l7 7m0 0l-7 7m7-7H3"
          />
        </svg>
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
            <svg
              class="w-5 h-5 mr-1"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              >
              </path>
            </svg>
            Anterior
          </a>
        <% else %>
          <span class="relative inline-flex items-center px-4 py-2 text-sm font-medium border border-r-0 border-gray-300 rounded-l-md text-gray-400 bg-gray-100 cursor-not-allowed">
            <svg
              class="w-5 h-5 mr-1"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              >
              </path>
            </svg>
            Anterior
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
            Siguiente
            <svg
              class="w-5 h-5 ml-1"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7">
              </path>
            </svg>
          </a>
        <% else %>
          <span class="relative inline-flex items-center px-4 py-2 text-sm font-medium border border-gray-300 rounded-r-md text-gray-400 bg-gray-100 cursor-not-allowed">
            Siguiente
            <svg
              class="w-5 h-5 ml-1"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7">
              </path>
            </svg>
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
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-5 w-5 text-gray-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                      clip-rule="evenodd"
                    />
                  </svg>
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
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-5 w-5 text-gray-400"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                      clip-rule="evenodd"
                    />
                  </svg>
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
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class={"h-5 w-5 text-gray-400 hover:text-#{@color_theme}-500"}
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                clip-rule="evenodd"
              />
            </svg>
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
      <ol class="inline-flex items-center space-x-1">
        <%= for {item, index} <- Enum.with_index(@items) do %>
          <li class="flex items-center">
            <%= if index > 0 do %>
              <%= if @separator_svg do %>
                <svg class="w-4 h-4 mx-1" fill="currentColor" viewBox="0 0 20 20">
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
              <.link navigate={item.href} class={"hover:text-#{@color_theme}-700 truncate"}>
                {item.text}
              </.link>
            <% else %>
              <span class={"text-gray-700 truncate max-w-[150px] md:max-w-[300px] #{if index == length(@items) - 1, do: "font-medium", else: ""}"}>
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

  # Helper para determinar si un enlace está activo
  defp active_class(nil, _link), do: ""
  defp active_class(_current_path, "#"), do: ""

  defp active_class(current_path, link) do
    if current_path == link, do: "bg-#{Config.webpage_theme()}-700 text-white", else: ""
  end
end
