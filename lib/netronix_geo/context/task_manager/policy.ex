defmodule NetronixGeo.Context.TaskManager.Policy do
  @moduledoc """
  The TaskManager.Policy contains policy information about user permissions
  """

  alias NetronixGeo.Model.User

  @type action :: :task_creation | :task_status_update

  @behaviour Bodyguard.Policy

  @spec authorize(action, User.t(), any()) :: boolean
  def authorize(:task_creation, %User{roles: roles}, _),
    do: Enum.any?(roles, &Kernel.==(&1.name, "Manager"))

  def authorize(:task_status_update, %User{roles: roles}, _),
    do: Enum.any?(roles, &Kernel.==(&1.name, "Driver"))

  def authorize(_, _, _), do: false
end
