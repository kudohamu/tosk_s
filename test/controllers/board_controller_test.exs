defmodule Tosk.BoardControllerTest do
  use Tosk.ConnCase

  alias Tosk.Board
  alias Tosk.User
  alias Tosk.UsersBoards

  @valid_attrs %{category: 2, name: "hogehoge"}
  @invalid_attrs %{category: 300, name: "hugahuga"}

  setup do
    user = Repo.insert(%User{hashed_password: "somecontent", icon: "somecontent.png", mail: "hogehoge@example.com", name: "hogehoge", provider: "own"})
    { conn, token } = User.set_token(conn() |> get("/"))
    conn = conn |> configure_session(:nil) |> put_req_header("accept", "application/json")
    {:ok, conn: conn, user: user, token: token}
  end

  #  test "lists all entries on index", %{conn: conn} do
  #    conn = get conn, board_path(conn, :index)
  #    assert json_response(conn, 200)["data"] == []
  #  end
  #
  #  test "shows chosen resource", %{conn: conn} do
  #    board = Repo.insert %Board{}
  #    conn = get conn, board_path(conn, :show, board)
  #    assert json_response(conn, 200)["data"] == %{
  #      "id" => board.id
  #    }
  #  end

  test "creates and renders resource when data is valid", %{conn: conn, user: user, token: token} do
    conn = conn |> put_req_header("authorization", "#{user.id}:#{token}")
    conn = post conn, board_path(conn, :create), board: @valid_attrs
    assert json_response(conn, 200)["id"]
    assert Repo.get_by(Board, @valid_attrs)
    assert Repo.get_by(UsersBoards, %{board_id: json_response(conn, 200)["id"]})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: user, token: token} do
    conn = conn |> put_req_header("authorization", "#{user.id}:#{token}")
    conn = post conn, board_path(conn, :create), board: @invalid_attrs
    assert json_response(conn, 422)["msg"] == "failed_to_creating_board"
  end

  test "does not create resource and renders errors when token is invalid", %{conn: conn, user: user, token: token} do
    conn = conn |> put_req_header("authorization", "#{user.id}:hogehogehogehoge")
    conn = post conn, board_path(conn, :create), board: @valid_attrs
    assert json_response(conn, 401)["msg"] == "unauthorized"
  end

  test "does not create resource and renders errors when Authorization header is empty", %{conn: conn, user: user, token: token} do
    conn = post conn, board_path(conn, :create), board: @valid_attrs
    assert json_response(conn, 401)["msg"] == "unauthorized"
  end


  #  test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #    board = Repo.insert %Board{}
  #    conn = put conn, board_path(conn, :update, board), board: @valid_attrs
  #    assert json_response(conn, 200)["data"]["id"]
  #    assert Repo.get_by(Board, @valid_attrs)
  #  end
  #
  #  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #    board = Repo.insert %Board{}
  #    conn = put conn, board_path(conn, :update, board), board: @invalid_attrs
  #    assert json_response(conn, 422)["errors"] != %{}
  #  end
  #
  #  test "deletes chosen resource", %{conn: conn} do
  #    board = Repo.insert %Board{}
  #    conn = delete conn, board_path(conn, :delete, board)
  #    assert json_response(conn, 200)["data"]["id"]
  #    refute Repo.get(Board, board.id)
  #  end
  
end
