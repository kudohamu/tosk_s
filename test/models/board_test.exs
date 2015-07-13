defmodule Tosk.BoardTest do
  use Tosk.ModelCase

  alias Tosk.Board

  @valid_attrs %{category: 2, uid: Ecto.UUID.generate(), name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid_attrs" do
    changeset = Board.changeset(%Board{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with empty category" do
    changeset = Board.changeset(%Board{}, Map.delete(@valid_attrs, :category))
    refute changeset.valid?
  end

  test "changeset with '1' category" do
    changeset = Board.changeset(%Board{}, Map.put(@valid_attrs, :category, 1))
    assert changeset.valid?
  end

  test "changeset with '3' category" do
    changeset = Board.changeset(%Board{}, Map.put(@valid_attrs, :category, 3))
    refute changeset.valid?
  end

  test "changeset with '0' category" do
    changeset = Board.changeset(%Board{}, Map.put(@valid_attrs, :category, 0))
    refute changeset.valid?
  end

  test "changeset with empty name" do
    changeset = Board.changeset(%Board{}, Map.delete(@valid_attrs, :name))
    refute changeset.valid?
  end
end
