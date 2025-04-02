# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias Policia.Articles

# Crear categorías
{:ok, noticias} = Articles.create_category(%{name: "Noticias", description: "Noticias generales"})

{:ok, seguridad} =
  Articles.create_category(%{name: "Seguridad", description: "Noticias sobre seguridad"})

{:ok, operativos} =
  Articles.create_category(%{
    name: "Operativos",
    description: "Información sobre operativos policiales"
  })

{:ok, capacitacion} =
  Articles.create_category(%{name: "Capacitación", description: "Eventos de capacitación"})

# Crear artículos
Articles.create_article(%{
  title: "Nuevo sistema de monitoreo para la seguridad vial",
  content:
    "La Policía de Río Negro implementa un moderno sistema de cámaras y monitoreo para mejorar la seguridad en las rutas provinciales.",
  image_url: "/images/demo/featured1.png",
  author: "Departamento de Prensa",
  category_id: seguridad.id
})

Articles.create_article(%{
  title: "Capacitación en primeros auxilios para el personal policial",
  content:
    "Más de 200 efectivos participaron del programa de capacitación en primeros auxilios y RCP, vital para situaciones de emergencia.",
  image_url: "/images/demo/featured2.png",
  author: "Departamento de Formación",
  category_id: capacitacion.id
})

Articles.create_article(%{
  title: "Inauguración de nueva comisaría en El Bolsón",
  content:
    "La nueva dependencia policial cuenta con tecnología de punta y mejores instalaciones para la atención al público.",
  image_url: "/images/demo/featured3.png",
  author: "Dirección General",
  category_id: noticias.id
})

Articles.create_article(%{
  title: "Operativo conjunto con fuerzas federales en zonas fronterizas",
  content:
    "La Policía provincial participó de un operativo de control de fronteras junto a Gendarmería y Prefectura Naval.",
  image_url: "/images/demo/news6.png",
  author: "División Operaciones",
  category_id: operativos.id
})
