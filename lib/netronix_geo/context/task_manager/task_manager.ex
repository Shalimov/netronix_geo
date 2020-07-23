defmodule NetronixGeo.Context.TaskManager do
  @moduledoc """
  The TaskManager context.
  """

  import Ecto.Query, only: [from: 2, from: 1], warn: false
  import Geo.PostGIS, only: [st_distance: 2]

  alias __MODULE__
  alias NetronixGeo.Repo
  alias NetronixGeo.Model.{Task, User}

  defdelegate authorize(action, user, params), to: TaskManager.Policy

  @doc """
  Returns the list of tasks by status

  Where status can be "assigned", "completed", "all"
  Only manger can list task by status

  ## Examples

    iex> list_nearest_tasks()
    [%Task{}, ...]

  """
  def list_tasks(user, status \\ "all") when status in ["assigned", "completed", "all"] do
    with :ok <- Bodyguard.permit(TaskManager.Policy, :list_tasks_by_status, user) do
      query =
        case status do
          "completed" -> from task in Task, where: not is_nil(task.completed_at)
          "assigned" -> from task in Task, where: not is_nil(task.assigned_at)
          _ -> from(task in Task)
        end

      Repo.all(query)
    end
  end

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
  @spec create_task!(User.t(), {float(), float()}, {float(), float()}) :: Task.t() | no_return()
  def create_task!(user, pickup_coords, delivery_coords) do
    with :ok <- Bodyguard.permit!(TaskManager.Policy, :task_creation, user) do
      %Task{}
      |> Task.create_changeset(%{
        creator: user,
        pickup_point: Task.to_gis_point(pickup_coords),
        delivery_point: Task.to_gis_point(delivery_coords)
      })
      |> Repo.insert!()
    end
  end

  @doc """
  Assigns task to a driver

  Only Driver role is available to assign task to itself (if task is not assigned)
  Manager is not able to set status assignee and change the status of task
  """
  @spec assign_task!(non_neg_integer(), User.t()) :: :ok | no_return()
  def assign_task!(task_id, user) do
    with :ok <- Bodyguard.permit!(TaskManager.Policy, :task_status_update, user) do
      query =
        from task in Task,
          where: task.id == ^task_id and is_nil(task.assignee_id),
          preload: [:assignee]

      task = Repo.one!(query)

      Task.assign_changeset(task, %{assignee: user})
      |> Repo.update!()
    end

    :ok
  end

  @doc """
  Sets completion status by setting complete_at property for a task

  Only Driver role is available to set a task completion statu (if driver is already an owner of the task)
  Manager is not able to change the status of task
  """
  @spec complete_task!(non_neg_integer(), User.t()) :: :ok | no_return()
  def complete_task!(task_id, user) do
    with :ok <- Bodyguard.permit!(TaskManager.Policy, :task_status_update, user) do
      query =
        from task in Task,
          where: task.id == ^task_id and task.assignee_id == ^user.id

      task = Repo.one!(query)

      Task.complete_changeset(task)
      |> Repo.update!()
    end

    :ok
  end
end
