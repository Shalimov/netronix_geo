defmodule NetronixGeo.Model.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Geo.PostGIS.Geometry
  alias NetronixGeo.Model

  schema "tasks" do
    field :pickup_point, Geometry
    field :delivery_point, Geometry

    field :assigned_at, :naive_datetime
    field :completed_at, :naive_datetime

    belongs_to :assignee, Model.User, foreign_key: :assignee_id
    belongs_to :creator, Model.User, foreign_key: :creator_id

    timestamps(updated_at: false)
  end
end
