defmodule Tosk.BoardView do
  use Tosk.Web, :view

  def render("index.json", %{boards: boards}) do
    %{
      result: "ok",
      boards: render_many(boards, "board.json")
    }
  end

  def render("show.json", %{board: board}) do
    %{
      board: render_one(board, "board.json")
    }
  end

  def render("create.json", %{board: board}) do
    %{
      result: "ok",
      board: board,
    }
  end

  def render("board.json", %{board: board}) do
    %{
      id: board.id,
      name: board.name,
    }
  end

  def render("delete.json", %{}) do
    %{
      result: "ok",
    }
  end
end
