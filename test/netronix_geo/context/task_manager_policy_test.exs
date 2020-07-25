defmodule NetronixGeo.TaskManagerPolicyTest do
  use ExUnit.Case

  alias NetronixGeo.Model.{User, Role}
  alias NetronixGeo.Context.TaskManager.Policy

  for {action, description} <- [
        task_creation: "Task creation action's policy",
        list_tasks_by_status: "List by status action's policy"
      ] do
    describe description do
      test """
      When user is a driver
      Then returns {:error, :unauthorized}
      """ do
        assert Bodyguard.permit(Policy, unquote(action), %User{roles: [%Role{name: "Driver"}]}) ==
                 {:error, :unauthorized}
      end

      test """
      When user is a manager
      Then returns :ok
      """ do
        assert Bodyguard.permit(Policy, unquote(action), %User{roles: [%Role{name: "Manager"}]}) ==
                 :ok
      end

      test """
      When user is anybody else
      Then returns {:error, :unauthorized}
      """ do
        assert Bodyguard.permit(Policy, unquote(action), %User{roles: [%Role{name: "Dodo"}]}) ==
                 {:error, :unauthorized}

        assert Bodyguard.permit(Policy, unquote(action), %User{roles: []}) ==
                 {:error, :unauthorized}

        assert Bodyguard.permit(Policy, unquote(action), %{}) == {:error, :unauthorized}
      end
    end
  end

  describe "Task update action's policy" do
    test """
    When user is a driver
    Then returns :ok
    """ do
      assert Bodyguard.permit(Policy, :task_status_update, %User{roles: [%Role{name: "Driver"}]}) ==
               :ok
    end

    test """
    When user is a manager
    Then returns {:error, :unauthorized}
    """ do
      assert Bodyguard.permit(Policy, :task_status_update, %User{roles: [%Role{name: "Manager"}]}) ==
               {:error, :unauthorized}
    end

    test """
    When user is anybody else
    Then returns {:error, :unauthorized}
    """ do
      assert Bodyguard.permit(Policy, :task_status_update, %User{roles: [%Role{name: "Dodo"}]}) ==
               {:error, :unauthorized}

      assert Bodyguard.permit(Policy, :task_status_update, %User{roles: []}) ==
               {:error, :unauthorized}

      assert Bodyguard.permit(Policy, :task_status_update, %{}) == {:error, :unauthorized}
    end
  end
end
