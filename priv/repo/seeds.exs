alias Policia.Repo
alias Policia.Accounts.User
alias Policia.Articles.Category
alias Policia.Articles.Article

# Eliminar datos existentes
Repo.delete_all(Article)
Repo.delete_all(Category)
Repo.delete_all(User)

# Crear usuarios con diferentes roles
# Asignamos explícitamente el rol "admin" al primer usuario
{:ok, admin_user} =
  %User{}
  |> User.registration_changeset(%{
    username: "admin",
    first_name: "Admin",
    last_name: "Usuario",
    email: "admin@ejemplo.com",
    password: "123123123123",
    # Asignar explícitamente el rol admin
    role: "admin"
  })
  |> Repo.insert()

{:ok, editor_user} =
  %User{}
  |> User.registration_changeset(%{
    username: "editor",
    first_name: "Editor",
    last_name: "Usuario",
    email: "editor@ejemplo.com",
    password: "123123123123",
    role: "editor"
  })
  |> Repo.insert()

{:ok, writer_user} =
  %User{}
  |> User.registration_changeset(%{
    username: "writer",
    first_name: "Writer",
    last_name: "Usuario",
    email: "writer@ejemplo.com",
    password: "123123123123",
    role: "writer"
  })
  |> Repo.insert()

{:ok, reader_user} =
  %User{}
  |> User.registration_changeset(%{
    username: "reader",
    first_name: "Reader",
    last_name: "Usuario",
    email: "reader@ejemplo.com",
    password: "123123123123",
    role: "reader"
  })
  |> Repo.insert()

# Crear categorías de seguridad y policía
categories_data = [
  %{
    name: "Seguridad Ciudadana",
    slug: "seguridad-ciudadana",
    description: "Noticias sobre iniciativas y acciones para mejorar la seguridad de la comunidad"
  },
  %{
    name: "Operativos Policiales",
    slug: "operativos-policiales",
    description: "Información sobre intervenciones y procedimientos policiales"
  },
  %{
    name: "Prevención del Delito",
    slug: "prevencion-delito",
    description: "Estrategias y programas para reducir la actividad criminal"
  },
  %{
    name: "Capacitación Policial",
    slug: "capacitacion-policial",
    description: "Noticias sobre formación, entrenamiento y desarrollo profesional"
  }
]

# Insertar categorías
categories =
  Enum.map(categories_data, fn category_attrs ->
    %Category{}
    |> Category.changeset(category_attrs)
    |> Repo.insert!()
  end)

# Generar artículos para cada categoría con diferentes usuarios
articles =
  Enum.flat_map(categories, fn category ->
    # Generar entre 2 y 4 artículos por categoría
    num_articles = Enum.random(2..4)

    Enum.map(1..num_articles, fn index ->
      # Seleccionar un usuario aleatorio para cada artículo
      random_user = Enum.random([admin_user, editor_user, writer_user, reader_user])

      %Article{}
      |> Article.changeset(%{
        title: "#{category.name} - Artículo #{index}",
        content: """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit.
        Nullam auctor, nunc eget ultricies tincidunt, velit velit
        bibendum velit, vel bibendum sapien nunc vel lectus.
        Fusce euismod, nunc sit amet aliquam lacinia, nisi enim
        lobortis enim, vel lacinia nunc enim eget nunc.

        Artículo creado por: #{random_user.username} (#{random_user.role})
        """,
        category_id: category.id,
        user_id: random_user.id,
        image_url: "/images/demo/imagen_de_prueba.png",
        featured_of_week: false
      })
      |> Repo.insert!()
    end)
  end)

# Marcar un artículo aleatorio como destacado de la semana
if length(articles) > 0 do
  featured_article = Enum.random(articles)

  featured_article
  |> Ecto.Changeset.change(featured_of_week: true)
  |> Repo.update!()

  IO.puts("Artículo '#{featured_article.title}' marcado como destacado de la semana.")
end

IO.puts("Seeds cargados exitosamente!")
