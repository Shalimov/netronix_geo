defmodule NetronixGeoWeb.TaskController do
  use NetronixGeoWeb, :controller

  alias NetronixGeo.Context.TaskManager

  action_fallback NetronixGeoWeb.FallbackController

  @doc "Creates a specific task with pickup coords and delivery coords"
  @spec create(Plug.Conn.t(), map()) ::
          Plug.Conn.t() | {:error, Ecto.Changeset} | {:error, any()}
  def create(conn, %{"pickup_coords" => [plng, plat], "delivery_coords" => [dlng, dlat]}) do
    current_user = Guardian.Plug.current_resource(conn)

    pickup_coords = {to_float(plng), to_float(plat)}
    delivery_coords = {to_float(dlng), to_float(dlat)}

    with {:ok, task} <- TaskManager.create_task(current_user, pickup_coords, delivery_coords) do
      json(conn, task)
    end
  end

  def create(_conn, _params), do: bad_request("Pick up and Delivery coordinates are required")

  @doc """
  Makes a specific task assigned to a specific driver
  """
  @spec assign(Plug.Conn.t(), map()) ::
          Plug.Conn.t() | {:error, Ecto.Changeset} | {:error, term()}
  def assign(conn, %{"id" => task_id}) do
    task_id = String.to_integer(task_id)
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- TaskManager.assign_task(current_user, task_id) do
      json(conn, %{status: "assigned"})
    end
  end

  @doc """
  Marks a specific task as accomplished by a specific driver
  """
  @spec complete(Plug.Conn.t(), map()) ::
          Plug.Conn.t() | {:error, Ecto.Changeset} | {:error, term()}
  def complete(conn, %{"id" => task_id}) do
    task_id = String.to_integer(task_id)
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- TaskManager.complete_task(current_user, task_id) do
      json(conn, %{status: "completed"})
    end
  end

  @doc """
  Returns nearest tasks to some specific coordinates
  """
  @spec list_nearest_tasks(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def list_nearest_tasks(conn, %{"lng" => lng, "lat" => lat}) do
    coords = {to_float(lng), to_float(lat)}

    with {:ok, tasks} <- TaskManager.list_nearest_tasks(coords) do
      json(conn, tasks)
    end
  end

  def list_nearest_tasks(_conn, _params),
    do: bad_request("Longitude (lng) and latitude (lat) should be defined")

  @doc """
  Returns tasks by status
  """
  @spec list_tasks(Plug.Conn.t(), map()) :: Plug.Conn.t() | {:error, term()}
  def list_tasks(conn, %{"status" => status}) when status in ["all", "completed", "assigned"] do
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, tasks} <- TaskManager.list_tasks(current_user, status) do
      json(conn, tasks)
    end
  end

  def list_tasks(_conn, _params),
    do: bad_request("Acceptable status could be one of: [completed, assigned, all]")

  defp bad_request(message),
    do: {:error, {:bad_request, message}}

  defp to_float(value) when is_binary(value), do: elem(Float.parse(value), 0)
end
