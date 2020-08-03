defmodule NetronixGeo.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table "tasks" do
      add :pickup_point, :point
      add :delivery_point, :point
      add :assigned_at, :naive_datetime
      add :completed_at, :naive_datetime
      add :creator_id, references(:users, on_delete: :nilify_all)
      add :assignee_id, references(:users, on_delete: :nilify_all)

      timestamps(updated_at: false)
    end

    create index "tasks", [:creator_id]
    create index "tasks", [:assignee_id]

    create index "tasks", [:pickup_point], using: "GIST"
    create index "tasks", [:delivery_point], using: "GIST"
  end
end
