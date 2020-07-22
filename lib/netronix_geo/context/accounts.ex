defmodule NetronixGeo.Context.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, only: [from: 2], warn: false
  alias Argon2

  alias NetronixGeo.Repo
  alias NetronixGeo.Model.User

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(non_neg_integer()) :: User.t()
  def get_user!(id) do
    query = from user in User, where: user.id == ^id, preload: [:roles]
    cleanup_user(Repo.one!(query))
  end

  @doc false
  @spec cleanup_user(%User{}) :: %User{}
  defp cleanup_user(user), do: %User{user | password: nil}
end
