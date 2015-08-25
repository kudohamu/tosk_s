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
  # broadcast to everyone in the current topic (todos:*).
  def handle_in("index", payload, socket) do
    "todos:" <> board_id = socket.topic
    todos_query = Ecto.Query.from td in TODO, 
      where: td.board_id == ^board_id
    todos = Repo.all(todos_query)
    jtodo = Enum.map(todos, 
      fn todo -> 
        case TODO.encodeTODOtoJSON(todo.id) do
          {:ok, jtodo} ->
            jtodo
          {:error} ->
            %{}
        end
      end)
    broadcast socket, "index", %{:data => jtodo}
    {:noreply, socket}
  end

  def handle_in("change", payload, socket) do
    case TODO.decodeJSONtoTODO(payload["todo"]) do
      {:ok, todo} ->
        {:ok, jtodo} = TODO.encodeTODOtoJSON(todo.id)
        broadcast socket, "changed", %{:todo => jtodo}
      {:error} ->
        {:noreply, socket}
    end
    {:noreply, socket}
  end

  def handle_in("create", payload, socket) do

    "todos:" <> board_id = socket.topic
    board = Repo.get(Board, board_id)
    if board do
      changeset = TODO.changeset(%TODO{}, %{ uid: Ecto.UUID.generate(), title: payload["title"], checked: false, content: "[]", board_id: board.id })
      if changeset.valid? do
        todo = Repo.insert(changeset)
        {:ok, jtodo} = TODO.encodeTODOtoJSON(todo.id)
        broadcast socket, "created", %{:todo => jtodo}
      end
    end
    {:noreply, socket}
  end

  def handle_in("delete", payload, socket) do
    "todos:" <> board_id = socket.topic
    todo = Repo.get_by(TODO, uid:  payload["id"])
    if todo && board_id == todo.board_id do
      case Repo.delete todo do
        {:error, _} ->
          {:noreply, socket}
        _ ->
          broadcast socket, "deleted", %{:id => todo.uid}
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
