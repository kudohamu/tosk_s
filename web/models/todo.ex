defmodule Tosk.TODO do
  use Tosk.Web, :model

  alias Tosk.Board
  alias Tosk.TODO

  import JSON

  schema "todos" do
    field :uid, :string
    field :public, :boolean, default: false
    field :checked, :boolean, default: false
    field :title, :string
    field :content, :string
    belongs_to :board, Tosk.Board

    timestamps
  end

  @required_fields ~w(uid title content board_id)
  @optional_fields ~w(public)

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

  def validate_public_only_template(changeset) do
    board = Tosk.Repo.get_by(Board, id: get_field(changeset, :board_id))
    if (board.category == 1 && get_field(changeset, :public)) do
      add_error(changeset, :"active_board_todo", "cannot be public")
    else 
      changeset
    end
  end

  # json用のmapにエンコードする
  def encodeTODOtoJSON(id) do
    todo = Tosk.Repo.get(TODO, id)

    if todo do
      case JSON.decode(todo.content) do
        {:ok, children} ->
          jtodo = %{ id: todo.id, content: todo.title, checked: todo.checked, children: children }
          {:ok, jtodo}
        _ ->
          {:error}
      end
    else
      {:error}
    end
  end
end
