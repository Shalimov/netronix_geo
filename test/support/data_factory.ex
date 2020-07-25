defmodule NetronixGeo.DataFactory do
  @moduledoc """
  Simple data factory to generate db records for tests
  """

  alias NetronixGeo.Repo
  alias NetronixGeo.Model.{User, Task, Role}

  def build(:role_manager) do
    %Role{name: "Manager"}
  end

  def build(:role_driver) do
    %Role{name: "Driver"}
  end

  def build(:user) do
    %User{email: "john.doe@email.com", password: "simple_password"}
  end

  def build(:task) do
    %Task{
      pickup_point: Task.to_gis_point({Enum.random(1..400), Enum.random(1..400)}),
      delivery_point: Task.to_gis_point({Enum.random(1..400), Enum.random(1..400)})
    }
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end

  def create_user(:manager), do: create_user(:role_manager)
  def create_user(:driver), do: create_user(:role_driver)

  def create_user(role_type) do
    {:ok, user} =
      Repo.transaction(fn ->
        role = Repo.insert!(build(role_type))

        user = build(:user, email: "john.doe+#{System.unique_integer()}@mail.com", roles: [role])
        Repo.insert!(user)
      end)

    user
  end
end
