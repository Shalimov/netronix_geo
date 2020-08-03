defmodule NetronixGeo.Context.TaskManagerTest do
  use NetronixGeo.DataCase
  import NetronixGeo.DataFactory

  alias NetronixGeo.Model.Task
  alias NetronixGeo.Context.TaskManager

  setup do
    %{
      manager: create_user(:manager),
      driver1: create_user(:driver),
      driver2: create_user(:driver)
    }
  end

  describe "TaskManager.create_task" do
    test """
         Given user with driver role
         When trying to create a task
         Then results {:error, :unauthorized}
         """,
         %{driver1: driver} do
      assert {:error, :unauthorized} = TaskManager.create_task(driver, {1, 1}, {10, 10})
    end

    test """
         Given user with manager role
         When trying to create a task
         Then results {:ok, %Task{}}
         """,
         %{manager: manager} do
      assert {:ok, %Task{}} = TaskManager.create_task(manager, {1, 1}, {10, 10})
    end

    test """
         Given user with manager role
         When trying to create a task with wrong coordinates
         Then raise Function clause error
         """,
         %{manager: manager} do
      assert_raise FunctionClauseError, fn ->
        TaskManager.create_task(manager, {"1", "1"}, {10, 10})
      end

      assert_raise FunctionClauseError, fn ->
        TaskManager.create_task(manager, {"1", "1"}, {"10", "10"})
      end

      assert_raise FunctionClauseError, fn ->
        TaskManager.create_task(manager, {"1", "1"}, [])
      end
    end
  end

  describe "TaskManager.assign_task" do
    test """
         Given user with manager role
         When trying to assign a task
         Then results {:error, :unauthorized}
         """,
         %{manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {1, 1})

      assert {:error, :unauthorized} = TaskManager.assign_task(manager, task.id)
    end

    test """
         Given user with driver role
         When trying to assign a task
         Then results {:ok, %Task{}}
         """,
         %{manager: manager, driver1: driver} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {1, 1})

      assert {:ok, %Task{}} = TaskManager.assign_task(driver, task.id)
    end

    test """
         Given user with driver role
         Given other user with driver role
         When trying to assign task which was already assigned
         Then results an {:error, :not_found}
         """,
         %{manager: manager, driver1: driver1, driver2: driver2} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {1, 1})

      assert {:ok, %Task{}} = TaskManager.assign_task(driver1, task.id)
      assert {:error, :not_found} = TaskManager.assign_task(driver2, task.id)
    end
  end

  describe "TaskManager.complete_task" do
    test """
         Given user with manager role
         When trying to complete a task
         Then results {:error, :unauthorized}
         """,
         %{manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {1, 1})

      assert {:error, :unauthorized} = TaskManager.complete_task(manager, task.id)
    end

    test """
         Given user with driver role
         When trying to complete a task which is not assigned
         Then results {:error, :not_found}
         """,
         %{manager: manager, driver1: driver} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {1, 1})

      assert {:error, :not_found} = TaskManager.complete_task(driver, task.id)
    end

    test """
         Given user with driver role
         When trying to complete a task which is assigned to other driver
         Then results {:error, :not_found
         """,
         %{manager: manager, driver1: driver1, driver2: driver2} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {1, 1})

      assert {:ok, %Task{}} = TaskManager.assign_task(driver1, task.id)
      assert {:error, :not_found} = TaskManager.complete_task(driver2, task.id)
    end

    test """
         Given user with driver role
         Given other user with driver role
         When trying to assign task which is already properly assigned
         Then gives the {:ok, %Task{}}
         """,
         %{manager: manager, driver1: driver} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {1, 1})

      assert {:ok, %Task{}} = TaskManager.assign_task(driver, task.id)
      assert {:ok, %Task{}} = TaskManager.complete_task(driver, task.id)
    end
  end

  describe "TaskManager.list_nearest_tasks" do
    test """
    When passing wrong params
    Then raise function clause error
    """ do
      assert_raise FunctionClauseError, fn ->
        TaskManager.list_nearest_tasks({"", ""})
      end

      assert_raise FunctionClauseError, fn ->
        TaskManager.list_nearest_tasks([])
      end
    end

    test """
         Given tasks created by manager
         When listing nearest tasks
         Then results nearest tasks
         """,
         %{manager: manager} do
      TaskManager.create_task(manager, {1, 1}, {20, 20})
      TaskManager.create_task(manager, {4, 5}, {50, 50})
      TaskManager.create_task(manager, {50, 70}, {50, 50})
      TaskManager.create_task(manager, {10, 10}, {50, 50})

      {:ok, tasks} = TaskManager.list_nearest_tasks({5, 5})

      assert Enum.map(
               tasks,
               &{{&1.pickup_point.x, &1.pickup_point.y},
                {&1.delivery_point.x, &1.delivery_point.y}}
             ) == [
               {{4.0, 5.0}, {50.0, 50.0}},
               {{1.0, 1.0}, {20.0, 20.0}},
               {{10.0, 10.0}, {50.0, 50.0}},
               {{50.0, 70.0}, {50.0, 50.0}}
             ]
    end
  end

  describe "TaskManager.list_tasks" do
    test """
         Given user with driver role
         When trying to list tasks by status [all, assigned, completed]
         Then results {:error, :unauthorized}
         """,
         %{driver1: driver} do
      assert {:error, :unauthorized} = TaskManager.list_tasks(driver, "all")
      assert {:error, :unauthorized} = TaskManager.list_tasks(driver, "completed")
      assert {:error, :unauthorized} = TaskManager.list_tasks(driver, "assigned")
    end

    test """
         Given user with manager role
         When trying to list tasks with wrong status (not all | completed | assign)
         Then raises no function clause error
         """,
         %{manager: manager} do
      assert {:ok, []} = TaskManager.list_tasks(manager, "all")
      assert {:ok, []} = TaskManager.list_tasks(manager, "completed")
      assert {:ok, []} = TaskManager.list_tasks(manager, "assigned")

      assert_raise FunctionClauseError, fn ->
        TaskManager.list_tasks(manager, "different")
      end
    end

    test """
         Given user with manager role
         When trying to list tasks by statuses
         Then results list of task with corresponding status
         """,
         %{manager: manager, driver1: driver} do
      assert {:ok, task} = TaskManager.create_task(manager, {1, 1}, {10, 10})
      assert {:ok, task_assigned} = TaskManager.create_task(manager, {1, 1}, {10, 11})
      assert {:ok, task_completed} = TaskManager.create_task(manager, {1, 1}, {10, 12})

      {:ok, all_tasks} = TaskManager.list_tasks(manager, "all")

      assert length(all_tasks) == 3

      {:ok, assigned_tasks} = TaskManager.list_tasks(manager, "assigned")

      assert assigned_tasks == []

      TaskManager.assign_task(driver, task_assigned.id)
      {:ok, assigned_tasks} = TaskManager.list_tasks(manager, "assigned")

      assert length(assigned_tasks) == 1

      {:ok, completed_tasks} = TaskManager.list_tasks(manager, "completed")

      assert completed_tasks == []

      TaskManager.assign_task(driver, task_completed.id)
      TaskManager.complete_task(driver, task_completed.id)

      {:ok, completed_tasks} = TaskManager.list_tasks(manager, "completed")

      assert length(completed_tasks) == 1
    end
  end
end
