defmodule NetronixGeo.Model.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Geo.{Point, PostGIS.Geometry}
  alias NetronixGeo.Model

  # SRID - corresponds to a spatial reference
  # system based on the specific ellipsoid used for either flat-earth mapping or round-earth mapping
  @srid 4326

  schema "tasks" do
    field :pickup_point, Geometry
    field :delivery_point, Geometry

    field :assigned_at, :naive_datetime
    field :completed_at, :naive_datetime

    belongs_to :assignee, Model.User
    belongs_to :creator, Model.User

    timestamps(updated_at: false)
  end

  @doc false
  @spec create_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def create_changeset(task, attrs) do
    task
    |> cast(attrs, [:pickup_point, :delivery_point])
    |> put_assoc(:creator, attrs.creator)
    |> validate_required([:pickup_point, :delivery_point, :creator])
  end

  @doc false
  @spec assign_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def assign_changeset(task, attrs) do
    change(task)
    |> put_assoc(:assignee, attrs.assignee)
    |> validate_required([:assignee])
    |> put_change(:assigned_at, current_time())
  end

  @doc false
  @spec complete_changeset(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def complete_changeset(task), do: put_change(task, :completed_at, current_time())

  @doc false
  @spec to_gis_point({float(), float()}) :: Point.t()
  def to_gis_point(coords), do: %Point{coordinates: coords, srid: @srid}

  @doc false
  @spec current_time() :: NaiveDateTime.t()
  defp current_time(), do: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :microsecond)
end
