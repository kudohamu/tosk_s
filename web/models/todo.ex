defmodule Tosk.TODO do
  use Tosk.Web, :model

  schema "todos" do
    field :uid, :string
    field :public, :boolean, default: false
    field :content, :string
    belongs_to :board, Tosk.Board

    timestamps
  end

  @required_fields ~w(uid public content)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_unique(:uid, on: Tosk.Repo)
  end
end
