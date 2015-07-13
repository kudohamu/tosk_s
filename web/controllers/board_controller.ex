defmodule Tosk.BoardController do
  use Tosk.Web, :controller

  alias Tosk.Board
  alias Tosk.User
  alias Tosk.UsersBoards

  plug :scrub_params, "board" when action in [:create, :update]
  plug :action

  def index(conn, %{ "category" => category }) do
    boards = Repo.select(:board_id).where()
    board_ids = Ecto.Query.from(ub in UsersBoards, where: ub.user_id == ^1, select: ub.board_id) |> Repo.all
    boards = Ecto.Query.from(ub in UsersBoards, where: ub.id in array(^board_ids, ^:integer)) |> Repo.all
    render(conn, "index.json", boards: boards)
  end

  def create(conn, %{"board" => board_params}) do
    changeset = Board.changeset(%Board{}, board_params)
    IO.puts get_req_header(conn, "authorization")
    case User.authorize?(conn) do
      :ok ->
      case Repo.transaction(fn ->
        if changeset.valid? do
          board = Repo.insert(changeset)
          usersboards_changeset = UsersBoards.changeset(%UsersBoards{}, %{user_id: 1, board_id: board.id })

          if usersboards_changeset.valid? do
            Repo.insert(usersboards_changeset)
            board.id
          else
            Repo.rollback(:error)
          end
        else
          Repo.rollback(:error)
        end
      end) do
      {:ok, board_id} ->
        render(conn, "create.json", %{ id: board_id })
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Tosk.ErrorView, "error.json", %{ msg: "failed_to_creating_board" })
      end
      :unauthorized ->
        conn
        |> put_status(:unauthorized)
        |> render(Tosk.ErrorView, "error.json", %{ msg: "unauthorized" })
    end
  end

  def update(conn, %{"id" => id, "board" => board_params}) do
    board = Repo.get(Board, id)
    changeset = Board.changeset(board, board_params)

    if changeset.valid? do
      board = Repo.update(changeset)
      render(conn, "show.json", board: board)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Tosk.ErrorView, "error.json", %{ msg: "failed_to_creating_board" })
    end
  end

  def delete(conn, %{"id" => id}) do
    board = Repo.get(Board, id)

    board = Repo.delete(board)
    render(conn, "show.json", board: board)
  end
end