defmodule Tosk.Board do
  use Tosk.Web, :model

  schema "boards" do
    field :name, :string
    field :category, :integer

    has_many :usersboards, HelloPhoenix.UsersBoards
    timestamps
  end

  @required_fields ~w(name category)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:category, 1..2)
  end
end
