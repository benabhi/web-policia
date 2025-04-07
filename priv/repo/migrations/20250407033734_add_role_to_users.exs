defmodule Policia.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, default: "reader"
    end

    # Crear un índice para mejorar las consultas por rol
    create index(:users, [:role])
  end
end
