defmodule Tosk.UserTest do
  use Tosk.ModelCase

  alias Tosk.User

  @valid_attrs %{hashed_password: "somecontent", icon: "somecontent.png", mail: "hogehoge@example.com", name: "hogehoge", provider: "own"}
  @invalid_attrs %{}

  test "changeset with valid attrs" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  ## icon
  test "changeset with valid png icon" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :icon, "hoge.png"))
    assert changeset.valid?
  end

  test "changeset with valid jpg icon" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :icon, "hoge.jpg"))
    assert changeset.valid?
  end

  test "changeset with valid jpeg icon" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :icon, "hoge.jpeg"))
    assert changeset.valid?
  end

  test "changeset with valid gif icon" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :icon, "hoge.gif"))
    refute changeset.valid?
  end

  ## name
  test "changeset with 4 character's name" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :name, "hoge"))
    assert changeset.valid?
  end

  test "changeset with 30 character's name" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :name, String.duplicate("h", 30)))
    assert changeset.valid?
  end

  test "changeset with 3 character's name" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :name, "hog"))
    refute changeset.valid?
  end

  test "changeset with 31 character's name" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :name, String.duplicate("h", 31)))
    refute changeset.valid?
  end

  ## mail
  test "changeset with invalid mail address" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :mail, "hogehoge.com"))
    refute changeset.valid?
  end

  test "changeset with ununique mail address" do
    Tosk.Repo.delete_all(User)
    user = Repo.insert(User.changeset(%User{}, @valid_attrs))
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :mail, "hogehoge@example.com"))
    refute changeset.valid?
  end

  ## provider
  test "changeset with own provider" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :provider, "own"))
    assert changeset.valid?
  end

  test "changeset with twitter provider" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :provider, "twitter"))
    assert changeset.valid?
  end

  test "changeset with facebook provider" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :provider, "facebook"))
    assert changeset.valid?
  end

  test "changeset with invalid provider" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :provider, "hogebook"))
    refute changeset.valid?
  end

  test "changeset with empty provider" do
    changeset = User.changeset(%User{}, Map.put(@valid_attrs, :provider, ""))
    refute changeset.valid?
  end
end
