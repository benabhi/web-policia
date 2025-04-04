alias Policia.Repo
alias Policia.Accounts.User
alias Policia.Articles.Category
alias Policia.Articles.Article

# Eliminar datos existentes
Repo.delete_all(Article)
Repo.delete_all(Category)
Repo.delete_all(User)

# Crear usuario
{:ok, user} =
  %User{}
  |> User.registration_changeset(%{
    username: "benabhi",
    first_name: "Hernan",
    last_name: "Jalanert",
    email: "benabhi@gmail.com",
    password: "123123123123"
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

# Generar artículos para cada categoría
Enum.each(categories, fn category ->
  # Generar entre 2 y 4 artículos por categoría
  num_articles = Enum.random(2..4)

  Enum.each(1..num_articles, fn index ->
    %Article{}
    |> Article.changeset(%{
      title: "#{category.name} - Artículo #{index}",
      content: """
      Lorem ipsum dolor sit amet, consectetur adipiscing elit.
      Nullam auctor, nunc eget ultricies tincidunt, velit velit
      bibendum velit, vel bibendum sapien nunc vel lectus.
      Fusce euismod, nunc sit amet aliquam lacinia, nisi enim
      lobortis enim, vel lacinia nunc enim eget nunc.
      """,
      category_id: category.id,
      user_id: user.id,
      image_url: "/images/demo/imagen_de_prueba.png"
    })
    |> Repo.insert!()
  end)
end)

IO.puts("Seeds cargados exitosamente!")
