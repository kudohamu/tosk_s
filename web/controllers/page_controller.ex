defmodule Tosk.PageController do
  use Tosk.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
