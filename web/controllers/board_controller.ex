defmodule Tosk.BoardController do
  use Tosk.Web, :controller

  import Ecto.Query, only: [where: 3]

  alias Tosk.Board
  alias Tosk.User
  alias Tosk.UsersBoards

  plug :scrub_params, "board" when action in [:create, :update]
  plug :action

  def index(conn, %{ }) do
    case User.authorize?(conn) do
      { :ok, id, token } ->
        ids_query = Ecto.Query.from ub in UsersBoards, 
        where: ub.user_id == ^id,
        select: ub.board_id
        board_ids = Repo.all(ids_query)

        boards_query = Ecto.Query.from b in Board, 
        where: b.id in ^board_ids
        boards = Repo.all(boards_query)
        render(conn, "index.json", %{ boards: boards })
      :unauthorized ->
        conn
        |> put_status(:unauthorized)
        |> render(Tosk.ErrorView, "error.json", %{ msg: "unauthorized" })
    end
  end

  def create(conn, %{"board" => board_params}) do
    changeset = Board.changeset(%Board{}, board_params)
    IO.puts get_req_header(conn, "authorization")
    case User.authorize?(conn) do
      { :ok, id, _ } ->
        case Repo.transaction(fn ->
          if changeset.valid? do
            board = Repo.insert(changeset)
            usersboards_changeset = UsersBoards.changeset(%UsersBoards{}, %{user_id: id, board_id: board.id })

            if usersboards_changeset.valid? do
              Repo.insert(usersboards_changeset)
              board
            else
              Repo.rollback(:error)
            end
          else
            Repo.rollback(:error)
          end
        end) do
          {:ok, board} ->
            render(conn, "create.json", board: %{ id: board.id, name: board.name })
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
      |> render(Tosk.ErrorView, "error.json", %{ msg: "failed_to_updating_board" })
    end
  end

  def delete(conn, %{"id" => id}) do
    case User.authorize?(conn) do
      { :ok, user_id, token } ->
        board = Repo.get(Board, id)
        usersboards = Repo.get_by(UsersBoards, user_id: user_id, board_id: id)

        Repo.delete(board)
        Repo.delete(usersboards)

        ids_query = Ecto.Query.from ub in UsersBoards, 
        where: ub.user_id == ^user_id,
        select: ub.board_id
        board_ids = Repo.all(ids_query)

        boards_query = Ecto.Query.from b in Board, 
        where: b.id in ^board_ids
        boards = Repo.all(boards_query)
        render(conn, "index.json", %{ boards: boards })
        #render(conn, 'delete.json", %{})
      :unauthorized ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Tosk.ErrorView, "error.json", %{ msg: "failed_to_creating_board" })
    end
  end
end
