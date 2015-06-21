defmodule Tosk.UserView do
  use Tosk.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id}
  end

  def render("create.json", %{id: id, token: token}) do
    %{
      result: "ok",
      id: id,
      token: token
    }
  end

  def render("error.json", %{msg: msg}) do
    %{
      result: :err,
      msg: msg
    }
  end
end
