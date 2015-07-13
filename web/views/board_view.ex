defmodule Tosk.BoardView do
  use Tosk.Web, :view

  def render("index.json", %{boards: boards}) do
    %{data: render_many(boards, "board.json")}
  end

  def render("show.json", %{board: board}) do
    %{data: render_one(board, "board.json")}
  end

  def render("create.json", %{id: id}) do
    %{
      result: "ok",
      id: id,
    }
  end

  def render("board.json", %{board: board}) do
    %{id: board.id}
  end
end
