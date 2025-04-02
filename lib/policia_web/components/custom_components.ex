defmodule PoliciaWeb.CustomComponents do
  use Phoenix.Component

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

  def nav_menu(assigns) do
    assigns =
      assign_new(assigns, :menu_id, fn ->
        "main-menu-" <> Integer.to_string(Enum.random(1000..9999))
      end)

    # Nota: Para que este componente funcione correctamente,
    # asegúrate de que tu archivo CSS global (app.css) incluya:
    # [x-cloak] { display: none !important; }

    ~H"""
    <div class="bg-blue-950 w-full">
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
            class="text-white hover:text-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-300 p-2 rounded-md transition-colors duration-200"
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
          class="fixed top-0 left-0 w-72 h-full bg-blue-950 shadow-lg transform z-40 overflow-y-auto"
          x-cloak
        >
          <!-- Encabezado del menú con botón para cerrar -->
          <div class="flex items-center justify-between p-4 border-b border-blue-900">
            <h2 class="text-xl font-semibold text-white">Menú</h2>
            <button
              @click="menuOpen = false; document.body.classList.remove('overflow-hidden')"
              class="text-white hover:text-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-300 rounded p-1"
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
                        class="flex justify-between items-center w-full py-2 px-4 text-white cursor-pointer focus:outline-none focus:bg-blue-800 hover:bg-blue-800 transition-colors duration-200"
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
                        class="mt-0 space-y-1 bg-blue-900"
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
                                class="flex justify-between items-center w-full py-2 px-6 text-blue-300 cursor-pointer focus:outline-none focus:bg-blue-800 hover:bg-blue-800 transition-colors duration-200"
                                @click="subOpen = !subOpen"
                                aria-expanded="false"
                                x-bind:aria-expanded="subOpen.toString()"
                              >
                                <span>{submenu.title}</span>
                                <svg
                                  class="ml-2 w-4 h-4 fill-current text-blue-300 transition-transform duration-300"
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
                                class="mt-0 space-y-1 bg-blue-800"
                                x-transition:enter="transition ease-out duration-200"
                                x-transition:enter-start="opacity-0 transform -translate-y-2"
                                x-transition:enter-end="opacity-100 transform translate-y-0"
                              >
                                <%= for subsubmenu <- submenu.submenus do %>
                                  <a
                                    href={subsubmenu.link}
                                    class={"py-2 px-8 block text-blue-300 hover:bg-blue-700 hover:text-white transition-colors duration-200 " <> active_class(@current_path, subsubmenu.link)}
                                  >
                                    {subsubmenu.title}
                                  </a>
                                <% end %>
                              </div>
                            </div>
                          <% else %>
                            <a
                              href={submenu.link}
                              class={"py-2 px-6 block text-blue-300 hover:bg-blue-700 hover:text-white transition-colors duration-200 " <> active_class(@current_path, submenu.link)}
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
                      class={"py-2 px-4 block text-white hover:bg-blue-800 hover:text-blue-200 transition-colors duration-200 " <> active_class(@current_path, menu.link)}
                    >
                      {menu.title}
                    </a>
                  <% end %>
                </li>
              <% end %>
            </ul>
          </nav>
        </div>
      </div>
      
    <!-- Versión desktop -->
      <div class="hidden md:block container mx-auto px-4">
        <div class="flex justify-between items-center py-2">
          <!-- Logo o nombre del sitio para desktop -->
          <div class="flex items-center">
            <a href="/" class="flex items-center text-white">
              <%= if @logo_src do %>
                <img src={@logo_src} alt={@site_name} class="h-10 w-auto mr-2" />
              <% end %>
              <span class="text-white font-semibold text-xl">{@site_name}</span>
            </a>
          </div>
          <!-- Menú principal desktop -->
          <nav class="flex-grow max-w-4xl mx-auto" aria-label="Menú principal">
            <ul class="flex justify-center space-x-6 py-3" role="menubar">
              <%= for menu <- @menus do %>
                <li
                  class="relative group px-2"
                  role="none"
                  x-data="{ open: false, timeoutId: null }"
                  x-init="$nextTick(() => { open = false })"
                  @mouseenter="clearTimeout(timeoutId); open = true"
                  @mouseleave="timeoutId = setTimeout(() => { open = false }, 300)"
                >
                  <%= if menu.submenus do %>
                    <button
                      type="button"
                      class="text-white hover:text-blue-200 flex items-center focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-opacity-50 rounded-md px-3 py-2 transition-colors duration-200"
                      aria-haspopup="true"
                      x-bind:aria-expanded="open.toString()"
                      @click="open = !open"
                      @mouseenter="clearTimeout(timeoutId); open = true"
                      role="menuitem"
                    >
                      <span>{menu.title}</span>
                      <svg
                        class="ml-2 w-4 h-4 fill-current text-white group-hover:text-blue-200 transition-colors duration-300"
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
                      class="absolute flex-col bg-blue-900 text-blue-300 mt-1 p-2 space-y-1 z-10 min-w-[300px] border border-blue-700 rounded-md shadow-lg"
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
                              class="block w-full text-left py-2 px-3 hover:bg-blue-800 rounded-md hover:text-white flex justify-between items-center focus:outline-none focus:bg-blue-700 focus:text-white transition-colors duration-200"
                              aria-haspopup="true"
                              x-bind:aria-expanded="subOpen.toString()"
                              @mouseenter="clearTimeout(subTimeoutId); subOpen = true"
                              role="menuitem"
                            >
                              <span>{submenu.title}</span>
                              <svg
                                class="ml-2 w-4 h-4 fill-current text-blue-300 group-hover/submenu:text-white transition-colors duration-300"
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
                              class="absolute flex-col bg-blue-800 text-blue-300 left-full top-0 p-2 space-y-1 z-20 min-w-[300px] border border-blue-700 rounded-md shadow-lg"
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
                                    class={"block py-2 px-3 hover:bg-blue-700 rounded-md hover:text-white focus:outline-none focus:bg-blue-600 focus:text-white transition-colors duration-200 " <> active_class(@current_path, subsubmenu.link)}
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
                              class={"block py-2 px-3 hover:bg-blue-800 rounded-md hover:text-white focus:outline-none focus:bg-blue-700 focus:text-white transition-colors duration-200 " <> active_class(@current_path, submenu.link)}
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
                      class={"text-white hover:text-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-opacity-50 rounded-md block px-3 py-2 transition-colors duration-200 " <> active_class(@current_path, menu.link)}
                      role="menuitem"
                    >
                      {menu.title}
                    </a>
                  <% end %>
                </li>
              <% end %>
            </ul>
          </nav>
        </div>
      </div>
    </div>
    """
  end

  # Helper para determinar si un enlace está activo
  defp active_class(nil, _link), do: ""
  defp active_class(_current_path, "#"), do: ""

  defp active_class(current_path, link) do
    if current_path == link, do: "bg-blue-700 text-white", else: ""
  end

  attr :image_src, :string, required: true, doc: "Ruta de la imagen destacada"
  attr :image_alt, :string, default: "Imagen destacada", doc: "Texto alternativo para la imagen"
  attr :date, :string, required: true, doc: "Fecha de publicación (formato: '01 Abril 2025')"
  attr :time, :string, required: true, doc: "Hora de publicación (formato: '02:49 AM')"
  attr :author, :string, required: true, doc: "Nombre del autor"
  attr :title, :string, required: true, doc: "Título del artículo"
  attr :category, :string, default: nil, doc: "Categoría del artículo"
  attr :comment_count, :integer, default: 0, doc: "Número de comentarios"
  slot :inner_block, required: true, doc: "Contenido del artículo"

  def article(assigns) do
    ~H"""
    <article class="bg-white text-gray-800 px-4 py-6 md:px-8 md:py-8 lg:px-12 lg:py-10 rounded-lg shadow-md border-t-4 border-blue-600">
      <!-- Imagen destacada con overlay de borde azul sutil -->
      <div class="mb-6 relative rounded-lg overflow-hidden shadow-md">
        <img src={@image_src} alt={@image_alt} class="w-full h-auto" />
        <div class="absolute inset-0 border-2 border-blue-200 opacity-50 pointer-events-none rounded-lg">
        </div>
      </div>
      
    <!-- Fecha, hora y autor con estilos mejorados -->
      <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center text-gray-500 text-sm mb-4">
        <p class="mb-2 sm:mb-0">
          <span class="text-blue-800">Publicado el:</span> <span class="font-medium">{@date}</span>
          <span class="text-blue-800 ml-1">a las</span> <span class="font-medium">{@time}</span>
        </p>
        <p>
          <span class="text-blue-800">Por:</span>
          <a
            href="#"
            class="font-medium text-blue-700 hover:text-blue-900 hover:underline transition-colors duration-200"
          >
            {@author}
          </a>
        </p>
      </div>
      
    <!-- Título con estilo adaptado a la paleta -->
      <h1 class="text-2xl sm:text-3xl font-bold mb-4 text-blue-950">
        {@title}
      </h1>
      
    <!-- Categoría en lugar de etiquetas -->
      <%= if @category do %>
        <div class="mb-6">
          <.badge text={@category} color="blue" size="md" />
        </div>
      <% end %>
      
    <!-- Contenido con mejor legibilidad -->
      <div class="text-gray-700 leading-relaxed space-y-4">
        {render_slot(@inner_block)}
      </div>
      
    <!-- Pie de página mejorado -->
      <div class="mt-8 pt-4 border-t border-gray-200">
        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4">
          <!-- Botones de compartir -->
          <div class="flex flex-wrap gap-3">
            <a
              href="#"
              class="inline-flex items-center text-blue-700 hover:text-blue-900 text-sm font-medium transition-colors duration-200"
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
              class="inline-flex items-center text-blue-700 hover:text-blue-900 text-sm font-medium transition-colors duration-200"
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
              class="inline-flex items-center text-blue-700 hover:text-blue-900 text-sm font-medium transition-colors duration-200"
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
              class="inline-flex items-center text-blue-700 hover:text-blue-900 transition-colors duration-200"
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
    </article>
    """
  end

  attr :sitename, :string,
    default: "Gobierno de Río Negro",
    doc: "Nombre del sitio que aparecerá en el footer"

  attr :slogan, :string,
    default: "Trabajando por nuestra provincia",
    doc: "Eslogan o descripción corta de la organización"

  attr :logo_src, :string,
    default: "",
    doc: "URL del logo, si es nil se usará un ícono SVG por defecto"

  attr :address, :string,
    default: "Av. 25 de Mayo 645, Viedma, Río Negro, Argentina",
    doc: "Dirección física de la organización"

  attr :phone, :string,
    default: "+54 (0920) 423-4567",
    doc: "Número de teléfono principal"

  attr :emails, :list,
    default: ["contacto@rionegro.gov.ar", "info@rionegro.gov.ar"],
    doc: "Lista de direcciones de correo electrónico"

  attr :copyright_year, :string,
    default: "2025",
    doc: "Año para mostrar en el aviso de copyright"

  attr :social_links, :list,
    default: [
      %{name: "Twitter", url: "#", icon: "twitter"},
      %{name: "Facebook", url: "#", icon: "facebook"},
      %{name: "Instagram", url: "#", icon: "instagram"},
      %{name: "YouTube", url: "#", icon: "youtube"}
    ],
    doc: "Lista de enlaces de redes sociales con nombre, URL e ícono"

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
    ~H"""
    <footer class={"bg-blue-950 text-white py-8 px-4 sm:px-6 border-t-4 border-blue-700 #{@class}"}>
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
                  class="h-10 w-10 text-blue-950"
                  viewBox="0 0 24 24"
                  fill="currentColor"
                >
                  <path d="M12 2L1 12h3v9h7v-6h2v6h7v-9h3L12 2z" />
                </svg>
              <% end %>
            </div>
            <div>
              <h2 class="text-xl font-bold">{@sitename}</h2>
              <p class="text-blue-300 text-sm">{@slogan}</p>
            </div>
          </div>
          
    <!-- Redes sociales -->
          <div>
            <h3 class="text-sm font-semibold mb-2 uppercase tracking-wider text-blue-300">
              Síguenos
            </h3>
            <div class="flex space-x-4">
              <%= for social <- @social_links do %>
                <a
                  href={social.url}
                  aria-label={social.name}
                  class="bg-blue-900 hover:bg-blue-800 p-2 rounded-full transition-colors duration-200"
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
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 border-b border-blue-900 pb-8 mb-6">
          <%= for column <- @menu_columns do %>
            <div>
              <h3 class="text-lg font-bold mb-4 border-b border-blue-800 pb-2 text-blue-200">
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
                            class="h-4 w-4 mr-2 text-blue-400"
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
                            class="h-4 w-4 mr-2 text-blue-400"
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
                          </svg>
                        <% link[:icon] == "user" -> %>
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            class="h-4 w-4 mr-2 text-blue-400"
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
                            class="h-4 w-4 mr-2 text-blue-400"
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
                            class="h-4 w-4 mr-2 text-blue-400"
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
                            class="h-4 w-4 mr-2 text-blue-400"
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
              class="h-5 w-5 mr-3 text-blue-400 mt-1 flex-shrink-0"
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
              <h4 class="text-blue-200 font-semibold mb-1">Dirección</h4>
              <p class="text-sm text-gray-300">{@address}</p>
            </div>
          </div>

          <div class="flex items-start">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 mr-3 text-blue-400 mt-1 flex-shrink-0"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path d="M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z" />
            </svg>
            <div>
              <h4 class="text-blue-200 font-semibold mb-1">Teléfono</h4>
              <p class="text-sm text-gray-300">{@phone}</p>
            </div>
          </div>

          <div class="flex items-start">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 mr-3 text-blue-400 mt-1 flex-shrink-0"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
              <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
            </svg>
            <div>
              <h4 class="text-blue-200 font-semibold mb-1">Email</h4>
              <%= for email <- @emails do %>
                <p class="text-sm text-gray-300">{email}</p>
              <% end %>
            </div>
          </div>
        </div>
        
    <!-- Derechos y política de privacidad -->
        <div class="border-t border-blue-900 pt-6 flex flex-col sm:flex-row justify-between items-center">
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
      assign(assigns,
        x_data: %{
          current: 0,
          totalSlides: length(assigns.images),
          autoSlide: assigns.auto_slide,
          slideInterval: assigns.slide_interval,
          paused: false
        }
      )

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
      class={"relative w-full overflow-hidden #{@height} #{if @rounded, do: "rounded-lg", else: ""} shadow-xl mb-8 border-2 border-blue-200 bg-blue-950"}
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
            <div class="absolute inset-0 bg-gradient-to-t from-blue-950/70 to-transparent"></div>
            
    <!-- Leyenda de la imagen si existe -->
            <%= if Enum.at(@captions, index) do %>
              <div class="absolute bottom-0 left-0 right-0 p-4 md:p-6 text-white">
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
        class="absolute left-4 top-1/2 transform -translate-y-1/2 bg-blue-800/70 hover:bg-blue-700 text-white w-10 h-10 rounded-full flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 transition-all duration-200"
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
        class="absolute right-4 top-1/2 transform -translate-y-1/2 bg-blue-800/70 hover:bg-blue-700 text-white w-10 h-10 rounded-full flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 transition-all duration-200"
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
            @click="current = #{index}"
            class={"w-3 h-3 rounded-full transition-all duration-300 " <>
              if(index == 0, do: "bg-white scale-110", else: "bg-white/50 hover:bg-white/80")}
            x-bind:class="current === #{index} ? 'bg-white scale-110' : 'bg-white/50 hover:bg-white/80'"
            aria-label={"Ir a la imagen #{index + 1}"}
          >
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  attr :title, :string, default: nil, doc: "Título principal de la sección de contenido"
  attr :subtitle, :string, default: nil, doc: "Subtítulo opcional de la sección"
  attr :wrapper_class, :string, default: "", doc: "Clases adicionales para el contenedor externo"
  slot :hero, doc: "Contenido destacado (slider, banner, etc.)"
  slot :inner_block, required: true, doc: "Contenido principal"

  def basic_content_layout(assigns) do
    ~H"""
    <div class={"bg-blue-50 py-8 md:py-12 #{@wrapper_class}"}>
      <div class="container mx-auto px-4 sm:px-6 lg:px-8">
        <%= if @title do %>
          <div class="mb-8 text-center">
            <h1 class="text-3xl sm:text-4xl font-bold text-blue-950 mb-2">{@title}</h1>
            <%= if @subtitle do %>
              <p class="text-lg text-blue-700">{@subtitle}</p>
            <% end %>
            <div class="w-20 h-1 bg-blue-600 mx-auto mt-4"></div>
          </div>
        <% end %>
        
    <!-- Área para contenido destacado (slider) -->
        <%= if render_slot(@hero) do %>
          <div class="mb-8">
            {render_slot(@hero)}
          </div>
        <% end %>
        
    <!-- Contenido principal sin barra lateral -->
        <div class="bg-white rounded-lg shadow-md p-4 sm:p-6 border border-blue-100">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  attr :title, :string, default: nil, doc: "Título principal de la sección de contenido"
  attr :subtitle, :string, default: nil, doc: "Subtítulo opcional de la sección"
  attr :has_sidebar, :boolean, default: true, doc: "Si debe mostrar la barra lateral"
  attr :wrapper_class, :string, default: "", doc: "Clases adicionales para el contenedor externo"
  slot :hero, doc: "Contenido destacado (slider, banner, etc.)"
  slot :sidebar, doc: "Contenido de la barra lateral"
  slot :inner_block, required: true, doc: "Contenido principal"

  def content_layout(assigns) do
    ~H"""
    <div>
      <%= if @title do %>
        <div class="mb-8 text-center">
          <h1 class="text-3xl sm:text-4xl font-bold text-blue-950 mb-2">{@title}</h1>
          <%= if @subtitle do %>
            <p class="text-lg text-blue-700">{@subtitle}</p>
          <% end %>
          <div class="w-20 h-1 bg-blue-600 mx-auto mt-4"></div>
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
          <div class="bg-white rounded-lg shadow-md p-4 sm:p-6 border border-blue-100">
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

  # Nuevo componente para la barra lateral
  attr :title, :string, default: "Enlaces de interés", doc: "Título de la barra lateral"
  slot :inner_block, required: true, doc: "Contenido de la barra lateral"

  def sidebar(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-md border border-blue-100 overflow-hidden">
      <div class="bg-blue-900 text-white p-4">
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
    ~H"""
    <ul class="space-y-2">
      <%= for item <- @items do %>
        <li>
          <a
            href={item.url}
            class="flex items-center p-3 rounded-md transition-colors duration-200 hover:bg-blue-50 border border-transparent hover:border-blue-200 group"
          >
            <%= if item[:icon] do %>
              <div class="w-10 h-10 flex-shrink-0 flex items-center justify-center rounded-full bg-blue-100 text-blue-800 group-hover:bg-blue-200 mr-3">
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
              <span class="font-medium text-blue-900 group-hover:text-blue-700">{item.title}</span>
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

  attr :title, :string, required: true, doc: "Título del artículo"
  attr :date, :string, required: true, doc: "Fecha de publicación"
  attr :image, :string, default: nil, doc: "Imagen destacada (opcional)"
  attr :excerpt, :string, default: "", doc: "Extracto del artículo"
  attr :url, :string, required: true, doc: "URL del artículo completo"
  attr :category, :string, default: nil, doc: "Categoría del artículo"

  def article_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg overflow-hidden shadow-md hover:shadow-lg transition-shadow duration-300 border border-blue-100 flex flex-col h-full">
      <%= if @image do %>
        <div class="relative h-48 overflow-hidden">
          <img
            src={@image}
            alt={@title}
            class="w-full h-full object-cover transition-transform duration-300 hover:scale-105"
          />
          <%= if @category do %>
            <div class="absolute top-2 right-2">
              <.badge text={@category} color="blue" size="sm" />
            </div>
          <% end %>
        </div>
      <% end %>

      <div class="p-4 flex-grow">
        <div class="text-sm text-blue-700 mb-2">{@date}</div>
        <h3 class="font-bold text-lg text-blue-950 mb-2 hover:text-blue-700">
          <a href={@url} class="hover:underline">{@title}</a>
        </h3>
        <p class="text-gray-600 text-sm line-clamp-3 mb-4">{@excerpt}</p>
      </div>

      <div class="px-4 pb-4 mt-auto">
        <a
          href={@url}
          class="inline-flex items-center text-sm font-semibold text-blue-700 hover:text-blue-900"
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
        </a>
      </div>
    </div>
    """
  end

  attr :articles, :list, default: [], doc: "Lista de artículos a mostrar"

  attr :columns, :string,
    default: "grid-cols-1 md:grid-cols-2 lg:grid-cols-3",
    doc: "Clases para controlar las columnas"

  def article_grid(assigns) do
    ~H"""
    <div class={"grid gap-6 #{@columns}"}>
      <%= for article <- @articles do %>
        <.article_card
          title={article.title}
          date={article.date}
          image={article.image}
          excerpt={article.excerpt}
          url={article.url}
          category={article.category}
        />
      <% end %>
    </div>
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

    assigns = assign(assigns, color_classes: Map.get(colors, assigns.type, colors["info"]))

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

  attr :text, :string, required: true, doc: "Texto a mostrar en la etiqueta"

  attr :color, :string,
    default: "blue",
    doc: "Color base de la etiqueta (blue, green, red, yellow, etc.)"

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
    color_classes = Map.get(colors, assigns.color, colors["blue"])
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
end
