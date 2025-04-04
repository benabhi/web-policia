# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Policia.Repo.insert!(%Policia.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Configurar el directorio donde se guardarán las imágenes de artículos
File.mkdir_p!("priv/static/images/articles")
File.mkdir_p!("priv/static/images/demo")

# Cargar el módulo de seeds y ejecutarlo
Code.eval_string(File.read!("priv/repo/seeds/categories_articles.exs"))
Policia.Seeds.run()

IO.puts("¡Seeds completados con éxito!")
