defmodule NetronixGeo.Context.TaskManager do
  @moduledoc """
  The TaskManager context.
  """

  import Ecto.Query, only: [from: 2], warn: false
  import Geo.PostGIS, only: [st_distance: 2]

  alias NetronixGeo.Repo
  alias NetronixGeo.Model.{Task, User}

  @doc """
  Returns the list of nearest tasks.

  ## Examples

      iex> list_nearest_tasks()
      [%Task{}, ...]

  """
  @spec list_nearest_tasks({float(), float()}) :: list(Task.t()) | Ecto.QueryError
  def list_nearest_tasks(location) do
    query =
      from task in Task,
        where: is_nil(task.assignee_id),
        order_by: st_distance(^Task.to_gis_point(location), task.pickup_point),
        limit: 10

    Repo.all(query)
  end

  @doc """
  Creates task with defined pickup and delivery points

  Manager is only the role to have such an ability
  Driver role can not execute this operation
  """
  @spec create_task!(User.t(), {float(), float()}, {float(), float()}) :: Task.t()
  def create_task!(user, pickup_loc, delivery_loc) do
    %Task{}
    |> Task.create_changeset(%{
      creator: user,
      pickup_point: Task.to_gis_point(pickup_loc),
      delivery_point: Task.to_gis_point(delivery_loc)
    })
    |> Repo.insert!()
  end

  @doc """
  Assigns task to a driver

  Only Driver role is available to assign task to itself (if task is not assigned)
  Manager is not able to set status assignee and change the status of task
  """
  @spec assign_task!(non_neg_integer(), User.t()) :: :ok
  def assign_task!(task_id, user) do
    query =
      from task in Task,
        where: task.id == ^task_id and is_nil(task.assignee_id),
        preload: [:assignee]

    task = Repo.one!(query)

    Task.assign_changeset(task, %{assignee: user})
    |> Repo.update!()

    :ok
  end

  @doc """
  Sets completion status by setting complete_at property for a task

  Only Driver role is available to set a task completion statu (if driver is already an owner of the task)
  Manager is not able to change the status of task
  """
  @spec complete_task!(non_neg_integer(), User.t()) :: :ok
  def complete_task!(task_id, user) do
    query =
      from task in Task,
        where: task.id == ^task_id and task.assignee_id == ^user.id

    task = Repo.one!(query)

    Task.complete_changeset(task)
    |> Repo.update!()

    :ok
  end
end
