defmodule NetronixGeoWeb.TaskControllerTest do
  use NetronixGeoWeb.ConnCase
  import NetronixGeo.DataFactory

  alias NetronixGeo.Model.Task
  alias NetronixGeo.Context.TaskManager
  alias NetronixGeoWeb.Auth.Guardian.Plug, as: GPlug

  setup do
    %{
      manager: create_user(:manager),
      driver: create_user(:driver)
    }
  end

  describe "POST /api/tasks" do
    test """
         Given authorized request to create task
         Given driver account
         When passing params are invalid
         Then responds with 400 and bad request message
         """,
         %{conn: conn, driver: driver} do
      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> post("/api/tasks", %{"pickup_coords" => [], "delivery_coords" => []})

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Pick up and Delivery coordinates are required"
             }
    end

    test """
         Given authorized request to create task
         Given driver account
         Then responds with 403 and forbidden message
         """,
         %{conn: conn, driver: driver} do
      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> post("/api/tasks", %{"pickup_coords" => [1, 1], "delivery_coords" => [1, 1]})

      assert json_response(conn, 403)["errors"] == %{"detail" => "Forbidden"}
    end

    test """
         Given authorized request to create task
         Given manager account
         When pickup coords and delivery coords are correct
         Then returns created task
         """,
         %{conn: conn, manager: manager} do
      conn =
        conn
        |> GPlug.put_current_resource(manager)
        |> post("/api/tasks", %{"pickup_coords" => [1, 1], "delivery_coords" => [1, 1]})

      manager_id = manager.id

      assert %{
               "id" => _,
               "creator_id" => ^manager_id,
               "inserted_at" => _,
               "assigned_at" => nil,
               "assignee_id" => nil,
               "completed_at" => nil,
               "delivery_point" => [1, 1],
               "pickup_point" => [1, 1]
             } = json_response(conn, 200)
    end
  end

  describe "PATCH /api/tasks/:id/assign" do
    test """
         Given authorized request to assign task
         Given manager account
         Then responds with 403 and Forbidden message
         """,
         %{conn: conn, manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {2, 2})

      conn =
        conn
        |> GPlug.put_current_resource(manager)
        |> patch("/api/tasks/#{task.id}/assign")

      assert json_response(conn, 403)["errors"] == %{
               "detail" => "Forbidden"
             }
    end

    test """
         Given authorized request to assign task
         Given driver account
         When picking wrong task
         Then responds with 404 and Not Found
         """,
         %{conn: conn, driver: driver} do
      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> patch("/api/tasks/0/assign")

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    test """
         Given authorized request to assign task
         Given driver account
         When picking task which was already assigned
         Then responds with 404 and Not Found
         """,
         %{conn: conn, driver: driver, manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {2, 2})
      TaskManager.assign_task(driver, task.id)

      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> patch("/api/tasks/#{task.id}/assign")

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    test """
         Given authorized request to assign task
         Given driver account
         When task.id is correct and task is found and not assigned
         Then responds with 200 and status => assigned
         """,
         %{conn: conn, driver: driver, manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {2, 2})

      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> patch("/api/tasks/#{task.id}/assign")

      assert json_response(conn, 200) == %{"status" => "assigned"}
    end
  end

  describe "PATCH /api/tasks/:id/complete" do
    test """
         Given authorized request to complete task
         Given manager account
         Then responds with 403 and Forbidden message
         """,
         %{conn: conn, manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {2, 2})

      conn =
        conn
        |> GPlug.put_current_resource(manager)
        |> patch("/api/tasks/#{task.id}/complete")

      assert json_response(conn, 403)["errors"] == %{
               "detail" => "Forbidden"
             }
    end

    test """
         Given authorized request to complete task
         Given driver account
         When picking wrong task
         Then responds with 404 and Not Found
         """,
         %{conn: conn, driver: driver} do
      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> patch("/api/tasks/0/complete")

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    test """
         Given authorized request to complete task
         Given driver account
         When picking task which is not assigned
         Then responds with 404 and Not Found
         """,
         %{conn: conn, driver: driver, manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {2, 2})

      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> patch("/api/tasks/#{task.id}/complete")

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    test """
         Given authorized request to complete task
         Given driver account
         When picking task which is assigned on other driver
         Then responds with 404 and Not Found
         """,
         %{conn: conn, driver: driver, manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {2, 2})
      another_driver = create_user(:driver)

      TaskManager.assign_task(another_driver, task.id)

      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> patch("/api/tasks/#{task.id}/complete")

      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    test """
         Given authorized request to assign task
         Given driver account
         When task.id is correct and task is properly assigned
         Then responds with 200 and status => completed
         """,
         %{conn: conn, driver: driver, manager: manager} do
      {:ok, task} = TaskManager.create_task(manager, {1, 1}, {2, 2})
      TaskManager.assign_task(driver, task.id)

      conn =
        conn
        |> GPlug.put_current_resource(driver)
        |> patch("/api/tasks/#{task.id}/complete")

      assert json_response(conn, 200) == %{"status" => "completed"}
    end
  end

  describe "GET /api/tasks/nearest" do
    test """
         Given an authroized request
         When params are not correct (lng, lat)
         Then respond with 400 bad_request
         """,
         %{conn: conn} do
      conn = get(conn, "/api/tasks/nearest")

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Longitude (lng) and latitude (lat) should be defined"
             }
    end

    test """
         Given an authroized request
         Given repo without tasks
         When params contains desired latitude and longitude
         Then respond with an empty list
         """,
         %{conn: conn} do
      lng = 32
      lat = 55
      conn = get(conn, "/api/tasks/nearest?lng=#{lng}&lat=#{lat}")

      assert json_response(conn, 200) == []
    end

    test """
         Given an authroized request
         When params contains desired latitude and longitude
         Then respond with list of corresponding tasks
         """,
         %{conn: conn, manager: manager} do
      lng = 32
      lat = 55

      TaskManager.create_task(manager, {10, 10}, {20, 20})

      conn = get(conn, "/api/tasks/nearest?lng=#{lng}&lat=#{lat}")

      assert [
               %{
                 "id" => _,
                 "creator_id" => _,
                 "inserted_at" => _,
                 "assigned_at" => nil,
                 "assignee_id" => nil,
                 "completed_at" => nil,
                 "delivery_point" => [20.0, 20.0],
                 "pickup_point" => [10.0, 10.0]
               }
             ] = json_response(conn, 200)
    end
  end

  describe "GET /api/tasks/:status" do
    test """
         Given an authroized request
         When params are not correct (lng, lat)
         Then respond with 400 bad_request
         """,
         %{conn: conn, manager: manager} do
      conn =
        conn
        |> GPlug.put_current_resource(manager)
        |> get("/api/tasks/abracadabra")

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Acceptable status could be one of: [completed, assigned, all]"
             }
    end

    test """
         Given an authroized request
         When driver is trying to access endpoint
         Then respond with 403 forbidden
         """,
         %{conn: conn, driver: driver} do
      conn = GPlug.put_current_resource(conn, driver)
      conn = get(conn, "/api/tasks/all")

      assert json_response(conn, 403)["errors"] == %{
               "detail" => "Forbidden"
             }
    end

    test """
         Given an authroized request
         Given repo without tasks
         When status is all
         Then respond with all available tasks
         """,
         %{conn: conn, manager: manager} do
      TaskManager.create_task(manager, {10, 10}, {20, 20})

      conn = GPlug.put_current_resource(conn, manager)
      conn = get(conn, "/api/tasks/all")

      assert [
               %{
                 "id" => _,
                 "creator_id" => _,
                 "inserted_at" => _,
                 "assigned_at" => nil,
                 "assignee_id" => nil,
                 "completed_at" => nil,
                 "delivery_point" => [20.0, 20.0],
                 "pickup_point" => [10.0, 10.0]
               }
             ] = json_response(conn, 200)
    end

    test """
         Given an authroized request
         Given repo without tasks
         When status is assigned
         Then respond with assigned tasks
         """,
         %{conn: conn, manager: manager, driver: driver} do
      {:ok, task} = TaskManager.create_task(manager, {10, 10}, {20, 20})
      {:ok, task} = TaskManager.assign_task(driver, task.id)

      conn = GPlug.put_current_resource(conn, manager)
      conn = get(conn, "/api/tasks/assigned")

      %Task{id: id, assignee_id: assignee_id, assigned_at: assigned_at} = task

      assigned_at = NaiveDateTime.to_iso8601(assigned_at)

      assert [
               %{
                 "id" => ^id,
                 "creator_id" => _,
                 "inserted_at" => _,
                 "assigned_at" => ^assigned_at,
                 "assignee_id" => ^assignee_id,
                 "completed_at" => nil,
                 "delivery_point" => [20.0, 20.0],
                 "pickup_point" => [10.0, 10.0]
               }
             ] = json_response(conn, 200)
    end

    test """
         Given an authroized request
         Given repo without tasks
         When status is completed
         Then respond with completed tasks
         """,
         %{conn: conn, manager: manager, driver: driver} do
      {:ok, task} = TaskManager.create_task(manager, {10, 10}, {20, 20})

      TaskManager.assign_task(driver, task.id)
      {:ok, task} = TaskManager.complete_task(driver, task.id)

      %Task{
        id: id,
        assignee_id: assignee_id,
        assigned_at: assigned_at,
        completed_at: completed_at
      } = task

      conn = GPlug.put_current_resource(conn, manager)
      conn = get(conn, "/api/tasks/completed")

      assigned_at = NaiveDateTime.to_iso8601(assigned_at)
      completed_at = NaiveDateTime.to_iso8601(completed_at)

      assert [
               %{
                 "id" => ^id,
                 "creator_id" => _,
                 "inserted_at" => _,
                 "assigned_at" => ^assigned_at,
                 "assignee_id" => ^assignee_id,
                 "completed_at" => ^completed_at,
                 "delivery_point" => [20.0, 20.0],
                 "pickup_point" => [10.0, 10.0]
               }
             ] = json_response(conn, 200)
    end
  end
end
