defmodule NetronixGeoWeb.TaskController do
  use NetronixGeoWeb, :controller

  alias NetronixGeo.Context.TaskManager

  @doc """
  Creates a specific task with pickup coords and delivery coords
  """
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    %{"pickup_coords" => [plng, plat], "delivery_coords" => [dlng, dlat]} = params
    current_user = Guardian.Plug.current_resource(conn)
    task = TaskManager.create_task!(current_user, {plng, plat}, {dlng, dlat})

    json(conn, task)
  end

  @doc """
  Makes a specific task assigned to a specific driver
  """
  @spec assign(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def assign(conn, %{"id" => task_id}) do
    task_id = String.to_integer(task_id)
    current_user = Guardian.Plug.current_resource(conn)
    TaskManager.assign_task!(task_id, current_user)

    json(conn, :ok)
  end

  @doc """
  Marks a specific task as accomplished by a specific driver
  """
  @spec complete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def complete(conn, %{"id" => task_id}) do
    task_id = String.to_integer(task_id)
    current_user = Guardian.Plug.current_resource(conn)
    TaskManager.complete_task!(task_id, current_user)

    json(conn, :ok)
  end

  @doc """
  Returns nearest tasks to some specific coordinates
  """
  @spec list_nearest_tasks(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def list_nearest_tasks(conn, %{"lng" => lng, "lat" => lat}) do
    tasks = TaskManager.list_nearest_tasks({lng, lat})

    json(conn, tasks)
  end

  @doc """
  Returns tasks by status
  """
  @spec list_tasks(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def list_tasks(conn, %{"status" => status}) do
    current_user = Guardian.Plug.current_resource(conn)
    tasks = TaskManager.list_tasks(current_user, status)

    json(conn, tasks)
  end
end
