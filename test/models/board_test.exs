defmodule Tosk.BoardTest do
  use Tosk.ModelCase

  alias Tosk.Board

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid_attrs" do
    changeset = Board.changeset(%Board{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with empty name" do
    changeset = Board.changeset(%Board{}, Map.delete(@valid_attrs, :name))
    refute changeset.valid?
  end
end
