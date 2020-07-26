defmodule NetronixGeoWeb.Auth.Guardian do
  @moduledoc """
  Module implements Guarian callbacks
  to work with resources related to NetronixGeo app
  """
  use Guardian, otp_app: :netronix_geo

  alias NetronixGeo.Context.Accounts
  alias NetronixGeo.Model.User

  @spec subject_for_token(User.t(), any()) :: {:ok, binary()}
  def subject_for_token(%User{id: id}, _claims), do: {:ok, to_string(id)}
  def subject_for_token(_, _), do: {:error, :invalid_resource}

  @spec resource_from_claims(map()) ::
          {:error, :resource_not_found} | {:ok, User.t()}
  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end

  def decode_permissions_from_claims(%{"roles" => roles}), do: roles

  def all_permissions?(roles, %{roles: expected_roles}) do
    roles_set = MapSet.new(roles)
    exp_roles_set = MapSet.new(expected_roles)

    MapSet.equal?(roles_set, exp_roles_set)
  end

  def any_permissions?(roles, %{roles: expected_roles}) do
    roles_set = MapSet.new(roles)
    exp_roles_set = MapSet.new(expected_roles)

    MapSet.intersection(roles_set, exp_roles_set)
    |> MapSet.size()
    |> Kernel.>(0)
  end
end
