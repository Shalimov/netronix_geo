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
alias NetronixGeo.Model.{Role, User}

drivers = ["john.doe@driver.com", "jina.doe@driver.com"]
managers = ["mark.twain@manager.com", "andy.insomnia@manager.com"]
roles = ["Driver", "Manager"]

[driver_role, manager_role] =
  for role_name <- roles do
    Repo.insert!(Role.changeset(%Role{}, %{name: role_name}))
  end

for {email, role} <-
      Enum.zip(drivers ++ managers, [driver_role, driver_role, manager_role, manager_role]) do
  Repo.insert!(User.changeset(%User{}, %{email: email, password: "123456qQ", roles: [role]}))
end
