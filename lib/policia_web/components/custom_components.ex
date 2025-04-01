defmodule PoliciaWeb.CustomComponents do
  use Phoenix.Component

  attr :menus, :list,
    default: [],
    doc: "Lista de menús principales con enlaces y submenús opcionales."

  def menu(assigns) do
    ~H"""
    <div class="bg-blue-950 w-full">
      <nav class="container mx-auto px-4">
        <ul class="flex justify-center space-x-8 py-4">
          <%= for menu <- @menus do %>
            <li class="relative group px-2 pb-2">
              <%= if menu.submenus do %>
                <a href={menu.link} class="text-white hover:text-blue-200 flex items-center">
                  <span>{menu.title}</span>
                  <!-- Ícono de indicador de desplegable -->
                  <svg
                    class="ml-2 mt-1 w-4 h-4 fill-current text-white group-hover:text-blue-200 transition-colors duration-300"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 0 24 24"
                    aria-hidden="true"
                  >
                    <path d="M12 15l-6-6h12z" />
                  </svg>
                </a>
                <ul class="absolute hidden group-hover:flex flex-col bg-blue-900 text-blue-300 mt-2 p-2 space-y-0 z-10 transition-all duration-300 delay-100 min-w-[300px] border border-blue-500 rounded shadow-md">
                  <%= for submenu <- menu.submenus do %>
                    <li>
                      <a
                        href={submenu.link}
                        style="transition: color 0.3s ease;"
                        class="block py-1 px-3 hover:bg-blue-500 rounded hover:text-white"
                      >
                        {submenu.title}
                      </a>
                    </li>
                  <% end %>
                </ul>
              <% else %>
                <a href={menu.link} class="text-white hover:text-blue-200">
                  {menu.title}
                </a>
              <% end %>
            </li>
          <% end %>
        </ul>
      </nav>
    </div>
    """
  end

  attr :images, :list,
    default: [],
    doc: "Lista de URLs de imágenes para el slider"

  attr :auto_slide, :boolean,
    default: false,
    doc: "Habilita el deslizamiento automático entre imágenes"

  attr :slide_interval, :integer,
    # Por defecto 3 segundos
    default: 3000,
    doc: "Tiempo en milisegundos entre los deslizamientos automáticos"

  def slider(assigns) do
    # Creamos el JSON para Alpine.js en Elixir antes del template

    assigns =
      assign(assigns,
        x_data:
          Jason.encode!(%{
            current: 0,
            images: assigns.images,
            autoSlide: assigns.auto_slide,
            slideInterval: assigns.slide_interval
          })
      )

    ~H"""
    <div
      x-data={@x_data}
      x-init="
        if (autoSlide) {
          setInterval(() => {
            current = (current + 1) % images.length;
          }, slideInterval);
        }
      "
      class="relative w-full overflow-hidden"
    >
      <!-- Slider -->
      <div
        class="flex transition-transform duration-700 ease-in-out"
        x-bind:style="'transform: translateX(-' + (current * 100) + '%)'"
      >
        <template x-for="(image, index) in images" x-bind:key="index">
          <div class="flex-shrink-0 w-full">
            <img x-bind:src="image" alt="Slider image" class="w-full h-auto object-cover rounded" />
          </div>
        </template>
      </div>
      
    <!-- Controles -->
      <button
        @click="current = (current - 1 + images.length) % images.length"
        class="absolute left-0 top-1/2 transform -translate-y-1/2 bg-black bg-opacity-50 text-white p-2 rounded"
      >
        &#10094;
      </button>
      <button
        @click="current = (current + 1) % images.length"
        class="absolute right-0 top-1/2 transform -translate-y-1/2 bg-black bg-opacity-50 text-white p-2 rounded"
      >
        &#10095;
      </button>
      
    <!-- Indicadores -->
      <div class="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2">
        <template x-for="(image, index) in images" x-bind:key="index">
          <button
            @click="current = index"
            x-bind:class="current === index ? 'bg-white' : 'bg-gray-500'"
            class="w-3 h-3 rounded-full"
          >
          </button>
        </template>
      </div>
    </div>
    """
  end
end
