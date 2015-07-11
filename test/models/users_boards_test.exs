defmodule Tosk.UsersBoardsTest do
  use Tosk.ModelCase

  alias Tosk.UsersBoards

  @valid_attrs %{board: nil, user: nil}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UsersBoards.changeset(%UsersBoards{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UsersBoards.changeset(%UsersBoards{}, @invalid_attrs)
    refute changeset.valid?
  end
end
