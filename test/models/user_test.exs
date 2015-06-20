defmodule Tosk.UserTest do
  use Tosk.ModelCase

  alias Tosk.User

  @valid_attrs %{hased_password: "some content", icon: "some content", mail: "some content", name: "some content", provider: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
