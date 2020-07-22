defmodule NetronixGeo.Repo.Migrations.UserRoles do
  use Ecto.Migration

  def change do
    create table("user_roles", primary_key: false) do
      add :user_id, references("users"), null: false, primary_key: true
      add :role_id, references("roles"), null: false, primary_key: true
    end
  end
end
