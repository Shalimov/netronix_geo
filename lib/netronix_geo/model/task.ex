defmodule NetronixGeo.Model.Task do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias NetronixGeo.Postgres.PGPoint
  alias NetronixGeo.Model

  schema "tasks" do
    field :pickup_point, PGPoint
    field :delivery_point, PGPoint

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
  def complete_changeset(task) do
    change(task)
    |> put_change(:completed_at, current_time())
  end

  @doc false
  @spec current_time() :: NaiveDateTime.t()
  defp current_time(), do: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
end
