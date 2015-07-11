defmodule Tosk.UsersBoards do
  use Tosk.Web, :model

  schema "usersboards" do
    belongs_to :board, Tosk.Board
    belongs_to :user, Tosk.User

    timestamps
  end

  @required_fields ~w()
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
