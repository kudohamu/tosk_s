defmodule Tosk.User do
  use Tosk.Web, :model

  schema "users" do
    field :icon, :string
    field :name, :string
    field :mail, :string
    field :hased_password, :string
    field :provider, :string

    timestamps
  end

  @required_fields ~w(icon name mail hased_password provider)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
