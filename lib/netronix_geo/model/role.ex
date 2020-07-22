defmodule NetronixGeo.Model.Role do
  use Ecto.Schema
  import Ecto.Changeset

  alias NetronixGeo.Model

  schema "roles" do
    field :name, :string

    many_to_many :users, Model.User, join_through: "user_roles"
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
