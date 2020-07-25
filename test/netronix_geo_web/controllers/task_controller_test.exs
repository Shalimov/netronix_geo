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
      conn = GPlug.put_current_resource(conn, manager)
      conn = get(conn, "/api/tasks/abracadabra")

      assert json_response(conn, 400)["errors"] == %{
               "detail" => "Acceptable status could be one of: [completed, assigned, all]"
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
