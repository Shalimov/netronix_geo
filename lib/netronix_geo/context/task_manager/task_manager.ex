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
  defguardp is_coords(coords) when is_number(elem(coords, 0)) and is_number(elem(coords, 1))

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

      {:ok, Repo.all(query)}
    end
  end

  @doc """
  Returns the list of nearest tasks.

  ## Examples

      iex> list_nearest_tasks()
      [%Task{}, ...]

  """
  @spec list_nearest_tasks({float(), float()}) :: {:ok, list(Task.t())}
  def list_nearest_tasks(coords) when is_coords(coords) do
    query =
      from task in Task,
        where: is_nil(task.assignee_id),
        order_by: st_distance(^Task.to_gis_point(coords), task.pickup_point),
        limit: 10

    {:ok, Repo.all(query)}
  end

  @doc """
  Creates task with defined pickup and delivery points

  Manager is only the role to have such an ability
  Driver role can not execute this operation
  """
  @spec create_task(User.t(), {float(), float()}, {float(), float()}) ::
          {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def create_task(user, pickup_coords, delivery_coords)
      when is_coords(pickup_coords) and is_coords(delivery_coords) do
    with :ok <- Bodyguard.permit(TaskManager.Policy, :task_creation, user) do
      %Task{}
      |> Task.create_changeset(%{
        creator: user,
        pickup_point: Task.to_gis_point(pickup_coords),
        delivery_point: Task.to_gis_point(delivery_coords)
      })
      |> Repo.insert()
    end
  end

  @doc """
  Assigns task to a driver

  Only Driver role is available to assign task to itself (if task is not assigned)
  Manager is not able to set status assignee and change the status of task
  """
  @spec assign_task(User.t(), non_neg_integer()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()} | {:error, term()}
  def assign_task(user, task_id) do
    with :ok <- Bodyguard.permit(TaskManager.Policy, :task_status_update, user) do
      query =
        from task in Task,
          where: task.id == ^task_id and is_nil(task.assignee_id),
          preload: [:assignee]

      if task = Repo.one(query) do
        Task.assign_changeset(task, %{assignee: user})
        |> Repo.update()
      else
        {:error, :not_found}
      end
    end
  end

  @doc """
  Sets completion status by setting complete_at property for a task

  Only Driver role is available to set a task completion statu (if driver is already an owner of the task)
  Manager is not able to change the status of task
  """
  @spec complete_task(User.t(), non_neg_integer()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()} | {:error, term()}
  def complete_task(user, task_id) do
    with :ok <- Bodyguard.permit(TaskManager.Policy, :task_status_update, user) do
      query =
        from task in Task,
          where: task.id == ^task_id and task.assignee_id == ^user.id

      if task = Repo.one(query) do
        Task.complete_changeset(task)
        |> Repo.update()
      else
        {:error, :not_found}
      end
    end
  end
end
