defmodule NetronixGeo.Context.AccountsTest do
  use NetronixGeo.DataCase
  import NetronixGeo.DataFactory

  alias NetronixGeo.Repo
  alias NetronixGeo.Model.User
  alias NetronixGeo.Context.Accounts

  describe "users" do
    def user_fixture() do
      {:ok, user} =
        Repo.transaction(fn ->
          manager_role = build(:role_manager)
          Repo.insert!(manager_role)

          user =
            build(:user, %{
              email: "simple_user+#{System.unique_integer()}@manager.com",
              roles: [manager_role]
            })

          Repo.insert!(user)
        end)

      user
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == %User{user | password: nil}
    end

    test "get_user!/1 raises no result error when user id is not found in db" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(0)
      end
    end
  end
end
