defmodule Tosk.BoardChannel do
  use Tosk.Web, :channel

  alias Tosk.Board
  alias Tosk.UsersBoards

  def join("boards:" <> _user_id, payload, socket) do
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

  def handle_in("index", payload, socket) do
    "boards:" <> _user_id = socket.topic

    ids_query = Ecto.Query.from ub in UsersBoards, 
    where: ub.user_id == ^_user_id,
    select: ub.board_id
    board_ids = Repo.all(ids_query)

    boards_query = Ecto.Query.from b in Board, 
    where: b.id in ^board_ids
    boards = Repo.all(boards_query)

    jboards = Enum.map(boards, 
      fn board -> 
        %{ id: board.id, name: board.name }
      end
    )

    broadcast socket, "index", %{:boards => jboards}
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (boards:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
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
