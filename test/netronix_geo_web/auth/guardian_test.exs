defmodule NetronixGeoWeb.Auth.GuardianTest do
  use NetronixGeo.DataCase

  alias NetronixGeo.Repo
  alias NetronixGeo.Model.{User, Role}
  alias NetronixGeoWeb.Auth.Guardian

  test """
  Given user model to generate subject for token
  When passing it to Guardian.subject_for_token
  Then results {:ok, to_string(id)}
  """ do
    user = %User{id: 1}

    assert {:ok, "1"} = Guardian.subject_for_token(user, %{})
  end

  test """
  Given wrong arguments for subject function
  When passing them to Guardian.subject_for_token
  Then results {:ok, to_string(id)}
  """ do
    assert {:error, :invalid_resource} = Guardian.subject_for_token(%{}, %{})
    assert {:error, :invalid_resource} = Guardian.subject_for_token(nil, %{})
    assert {:error, :invalid_resource} = Guardian.subject_for_token([], %{})
  end

  test """
  Given user id for retrieving resource
  When passing them to Guardian.resource_from_claims
  Then results {:ok, user}
  """ do
    role = Repo.insert!(Role.changeset(%Role{}, %{name: "Role"}))

    user =
      Repo.insert!(User.changeset(%User{}, %{email: "mail", password: "123456", roles: [role]}))

    assert {:ok, %User{}} = Guardian.resource_from_claims(%{"sub" => user.id})
  end

  test """
  Given wrong user id
  When passing them to Guardian.resource_from_claims
  Then results {:error, :resource_not_found}
  """ do
    assert {:error, :resource_not_found} = Guardian.resource_from_claims(%{"sub" => 0})
  end
end
