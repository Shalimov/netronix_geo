defmodule NetronixGeo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add :email, :string, size: 255
      add :password, :string

      timestamps(updated_at: false)
    end

    create unique_index("users", [:email])
  end
end
