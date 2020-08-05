defmodule NetronixGeo.Context.TaskManager.Policy do
  @moduledoc """
  The TaskManager.Policy contains policy information about user permissions
  """

  alias NetronixGeo.Model.User

  @type action :: :complete_task | :assign_task | :create_task | :list_tasks

  @behaviour Bodyguard.Policy

  @spec authorize(action, User.t(), any()) :: boolean
  def authorize(action, %User{roles: roles}, _)
      when action in [:assign_task, :complete_task],
      do: Enum.any?(roles, &Kernel.==(&1.name, "Driver"))

  def authorize(action, %User{roles: roles}, _)
      when action in [:create_task, :list_tasks],
      do: Enum.any?(roles, &Kernel.==(&1.name, "Manager"))

  def authorize(_, _, _), do: false
end
