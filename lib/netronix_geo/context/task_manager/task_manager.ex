defmodule NetronixGeo.Context.TaskManager do
  @moduledoc """
  The TaskManager context.
  """

  import Ecto.Query, only: [from: 2, from: 1], warn: false

  import NetronixGeo.Authorize
  import NetronixGeo.Postgres.PGPoint.Operators

  alias __MODULE__
  alias NetronixGeo.Repo
  alias NetronixGeo.Model.{Task, User}

  defdelegate authorize(action, user, params), to: TaskManager.Policy
  defguardp is_coords(coords) when is_number(elem(coords, 0)) and is_number(elem(coords, 1))

  @doc """
  Returns the list of tasks by status

  Where status can be "assigned", "completed", "all"
  Only manger can list task by status
  NB!: (User is used behind the scene inside generated (by defauth) function)

  ## Examples

    iex> list_nearest_tasks()
    [%Task{}, ...]

  """
  @spec list_tasks(User.t(), String.t()) ::
          {:ok, list(Task.t())} | {:error, Ecto.Changeset.t()} | {:error, term()}
  defauth list_tasks(user, status) when status in ["assigned", "completed", "all"],
    policy: TaskManager.Policy do
    query =
      case status do
        "completed" -> from task in Task, where: not is_nil(task.completed_at)
        "assigned" -> from task in Task, where: not is_nil(task.assigned_at)
        "all" -> from(task in Task)
      end

    {:ok, Repo.all(query)}
  end

  @doc """
  Returns the list of nearest tasks.

  ## Examples

      iex> list_nearest_tasks()
      [%Task{}, ...]

  """
  @spec list_nearest_tasks({float(), float()}) :: {:ok, list(Task.t())}
  def list_nearest_tasks(coords) when is_coords(coords) do
    point = %Postgrex.Point{x: elem(coords, 0), y: elem(coords, 1)}

    query =
      from task in Task,
        where: is_nil(task.assignee_id),
        order_by: ^point <~> task.pickup_point,
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
  defauth create_task(user, pickup_coords, delivery_coords)
          when is_coords(pickup_coords) and is_coords(delivery_coords),
          policy: TaskManager.Policy do
    %Task{}
    |> Task.create_changeset(%{
      creator: user,
      pickup_point: pickup_coords,
      delivery_point: delivery_coords
    })
    |> Repo.insert()
  end

  @doc """
  Assigns task to a driver

  Only Driver role is available to assign task to itself (if task is not assigned)
  Manager is not able to set status assignee and change the status of task
  """
  @spec assign_task(User.t(), non_neg_integer()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()} | {:error, term()}
  defauth assign_task(user, task_id), policy: TaskManager.Policy do
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

  @doc """
  Sets completion status by setting complete_at property for a task

  Only Driver role is available to set a task completion statu (if driver is already an owner of the task)
  Manager is not able to change the status of task
  """
  @spec complete_task(User.t(), non_neg_integer()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()} | {:error, term()}
  defauth complete_task(user, task_id), policy: TaskManager.Policy do
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
