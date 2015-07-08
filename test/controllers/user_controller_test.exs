defmodule Tosk.UserControllerTest do
  use Tosk.ConnCase

  alias Tosk.User
  @valid_attrs %{icon: "somecontent.png", hashed_password: "somecontent", mail: "hogehoge@example.com", name: "hogehoge", provider: "own"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

#  test "lists all entries on index", %{conn: conn} do
#    conn = get conn, user_path(conn, :index)
#    assert json_response(conn, 200)["data"] == []
#  end
#
#  test "shows chosen resource", %{conn: conn} do
#    user = Repo.insert %User{}
#    conn = get conn, user_path(conn, :show, user)
#    assert json_response(conn, 200)["data"] == %{
#      "id" => user.id
#    }
#  end
#
#  test "creates and renders resource when data is valid", %{conn: conn} do
#    conn = post conn, user_path(conn, :create), user: @valid_attrs
#    assert json_response(conn, 200)["data"]["id"]
#    assert Repo.get_by(User, @valid_attrs)
#  end
#
#  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
#    conn = post conn, user_path(conn, :create), user: @invalid_attrs
#    assert json_response(conn, 422)["errors"] != %{}
#  end
#
#  test "updates and renders chosen resource when data is valid", %{conn: conn} do
#    user = Repo.insert %User{}
#    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
#    assert json_response(conn, 200)["data"]["id"]
#    assert Repo.get_by(User, @valid_attrs)
#  end
#
#  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
#    user = Repo.insert %User{}
#    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
#    assert json_response(conn, 422)["errors"] != %{}
#  end
#
#  test "deletes chosen resource", %{conn: conn} do
#    user = Repo.insert %User{}
#    conn = delete conn, user_path(conn, :delete, user)
#    assert json_response(conn, 200)["data"]["id"]
#    refute Repo.get(User, user.id)
#  end
#
  test "invalid combination of mail address and password" do
    changeset = User.changeset(%User{},  Map.put(@valid_attrs, :hashed_password, Comeonin.Bcrypt.hashpwsalt("hogehoge")))
    user = Repo.insert changeset
    conn = post conn, user_path(conn, :login), %{ mail: "hogehoge@example.com", password: "hugahuga" }
    assert json_response(conn, 200) == %{
      "result" => "err",
      "msg" => "invalid_combination_of_mail_address_and_password"
    }
  end

  test "valid combination of mail address and password" do
    changeset = User.changeset(%User{},  Map.put(@valid_attrs, :hashed_password, Comeonin.Bcrypt.hashpwsalt("hogehoge")))
    user = Repo.insert changeset
    conn = post conn, user_path(conn, :login), %{ mail: "hogehoge@example.com", password: "hogehoge" }
    assert json_response(conn, 200)["result"] == "ok"
    assert json_response(conn, 200)["id"] == user.id
    assert String.length(json_response(conn, 200)["token"]) > 0
    assert Comeonin.Bcrypt.checkpw(json_response(conn, 200)["token"], get_session(conn, :token))
  end
end
