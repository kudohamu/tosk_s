defmodule Tosk.TODOTest do
  use Tosk.ModelCase

  alias Tosk.TODO
  alias Tosk.Board

  @valid_attrs %{content: "some content", public: true, uid: "some content"}
  @invalid_attrs %{}

  test "changeset with duplicate uid" do
    board = Repo.insert(%Board{category: 2, uid: Ecto.UUID.generate(), name: "hogehoge"})
    uid = Ecto.UUID.generate()
    Repo.insert(TODO.changeset(%TODO{}, (Map.put(@valid_attrs, :uid, uid) |> Map.put(:board_id, board.id))))
    changeset = TODO.changeset(%TODO{}, (Map.put(@valid_attrs, :uid, uid) |> Map.put(:board_id, board.id)))
    refute changeset.valid?
  end

  test "changeset with unique uid" do
    board = Repo.insert(%Board{category: 2, uid: Ecto.UUID.generate(), name: "hogehoge"})
    uid = Ecto.UUID.generate()
    changeset = TODO.changeset(%TODO{}, (Map.put(@valid_attrs, :uid, uid) |> Map.put(:board_id, board.id)))
    assert changeset.valid?
  end

  test "public is true of active board's todo" do
    board = Repo.insert(%Board{category: 1, uid: Ecto.UUID.generate(), name: "hogehoge"})
    changeset = TODO.changeset(%TODO{}, %{board_id: board.id, content: "hoge", public: true, uid: Ecto.UUID.generate()})
    refute changeset.valid?
  end

  test "public is false of active board's todo" do
    board = Repo.insert(%Board{category: 1, uid: Ecto.UUID.generate(), name: "hogehoge"})
    changeset = TODO.changeset(%TODO{}, %{board_id: board.id, content: "hoge", public: false, uid: Ecto.UUID.generate()})
    assert changeset.valid?
  end

  test "public is true of template board's todo" do
    board = Repo.insert(%Board{category: 2, uid: Ecto.UUID.generate(), name: "hogehoge"})
    changeset = TODO.changeset(%TODO{}, %{board_id: board.id, content: "hoge", public: true, uid: Ecto.UUID.generate()})
    assert changeset.valid?
  end

  test "public is false of template board's todo" do
    board = Repo.insert(%Board{category: 2, uid: Ecto.UUID.generate(), name: "hogehoge"})
    changeset = TODO.changeset(%TODO{}, %{board_id: board.id, content: "hoge", public: false, uid: Ecto.UUID.generate()})
    assert changeset.valid?
  end

  test "changeset with empty content" do
    board = Repo.insert(%Board{category: 2, uid: Ecto.UUID.generate(), name: "hogehoge"})
    changeset = TODO.changeset(%TODO{}, %{board_id: board.id, public: false, uid: Ecto.UUID.generate()})
    refute changeset.valid?
  end
end
