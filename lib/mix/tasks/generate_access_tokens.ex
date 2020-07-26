defmodule Mix.Tasks.GenerateAccessTokens do
  @moduledoc """
  Module implements simple mix tasks to generate access tokens for all predifined users
  """

  use Mix.Task
  import Ecto.Query, only: [from: 2]

  alias NetronixGeo.{Repo, Model.User}
  alias NetronixGeoWeb.Auth.Guardian

  @shortdoc "Generates access tokens for existing DB users"
  def run(_) do
    Application.ensure_all_started(:netronix_geo)

    query = from user in User, preload: [:roles]

    query
    |> Repo.all()
    |> Enum.each(fn user ->
      {:ok, token, _payload} =
        Guardian.encode_and_sign(user, %{roles: Enum.map(user.roles, & &1.name)})

      IO.puts("""
      --------------------------------
        --EMAIL--: #{user.email}
        --TOKEN--: #{token}\
      """)
    end)
  end
end
