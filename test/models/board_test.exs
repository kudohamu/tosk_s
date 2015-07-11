defmodule Tosk.BoardTest do
  use Tosk.ModelCase

  alias Tosk.Board

  @valid_attrs %{category: 42, uid: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with duplicate uid" do
    uid = Ecto.UUID.generate()
    Repo.insert(Board.changeset(%Board{}, Map.put(@valid_attrs, :uid, uid)))
    changeset = Board.changeset(%Board{}, Map.put(@valid_attrs, :uid, uid))
    refute changeset.valid?
  end

  test "changeset with unique uid" do
    changeset = Board.changeset(%Board{}, Map.put(@valid_attrs, :uid, Ecto.UUID.generate()))
    assert changeset.valid?
  end
end
