defmodule NetronixGeo.Model.Token do
  use Ecto.Schema
  import Ecto.Changeset

  alias NetronixGeo.Model

  @primary_key {:token, :binary_id, autogenerate: false}

  schema "tokens" do
    belongs_to :user, Model.User, foreign_key: :user_id
  end
end
