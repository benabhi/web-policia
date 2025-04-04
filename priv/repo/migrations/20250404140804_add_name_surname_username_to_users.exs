defmodule Policia.Repo.Migrations.AddNameSurnameUsernameToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :username, :string, null: false
    end

    # Crear un índice único para username
    create unique_index(:users, [:username])
  end
end
