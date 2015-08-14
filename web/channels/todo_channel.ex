defmodule Tosk.TODOChannel do
  use Tosk.Web, :channel

  alias Tosk.User
  alias Tosk.Board
  alias Tosk.TODO

  def join("todos:" <> _board_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (todos:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("change", payload, socket) do
    broadcast socket, "change", payload
    {:noreply, socket}
  end

  def handle_in("create", payload, socket) do
    IO.puts payload["id"]
    IO.puts payload["token"]
    IO.puts payload["title"]
    IO.puts payload["boardId"]

    board = Repo.get(Board, payload["boardId"])
    if board do
      changeset = TODO.changeset(%TODO{}, %{ title: payload["title"], checked: false, content: "[]", board_id: board.id })
      if changeset.valid? do
        todo = Repo.insert(changeset)
        broadcast socket, "created", payload
      end
    end
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
