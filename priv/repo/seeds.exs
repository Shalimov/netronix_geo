# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     NetronixGeo.Repo.insert!(%NetronixGeo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias NetronixGeo.Repo
alias NetronixGeo.Model.{Role, User, Task}

drivers = ["john.doe@driver.com", "jina.doe@driver.com"]
managers = ["mark.twain@manager.com", "andy.insomnia@manager.com"]
roles = ["Driver", "Manager"]

tasks = [
  {{4, 3}, {9, 9}},
  {{5, 1}, {10, 23}},
  {{1, 1}, {10, 23}},
  {{9, 9}, {10, 23}},
  {{100, 200}, {402, 230}},
  {{105, 230}, {402, 230}},
  {{106, 210}, {452, 270}}
]

[driver_role, manager_role] =
  for role_name <- roles do
    Repo.insert!(Role.changeset(%Role{}, %{name: role_name}))
  end

[_, _, manager, _] =
  for {email, role} <-
        Enum.zip(drivers ++ managers, [driver_role, driver_role, manager_role, manager_role]) do
    Repo.insert!(User.changeset(%User{}, %{email: email, password: "123456qQ", roles: [role]}))
  end

for {pickup_point, delivery_point} <- tasks do
  task =
    Task.create_changeset(%Task{}, %{
      creator: manager,
      pickup_point: Task.to_gis_point(pickup_point),
      delivery_point: Task.to_gis_point(delivery_point)
    })

  Repo.insert!(task)
end
