defmodule Tosk.BoardChannel do
  use Tosk.Web, :channel

  alias Tosk.Board
  alias Tosk.TODO
  alias Tosk.UsersBoards

  def join("boards:" <> _board_id, payload, socket) do
    socket = assign(socket, :id, payload["id"])
    socket = assign(socket, :token, payload["token"])
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
    _user_id = socket.assigns.id

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

  def handle_in("create", payload, socket) do
    _user_id = socket.assigns.id

    changeset = Board.changeset(%Board{}, %{ name: payload["name"] })
    case Repo.transaction(fn ->
      if changeset.valid? do
        board = Repo.insert(changeset)
        usersboards_changeset = UsersBoards.changeset(%UsersBoards{}, %{ user_id: _user_id, board_id: board.id })

        if usersboards_changeset.valid? do
          Repo.insert(usersboards_changeset)
          board
        else
          Repo.rollback(:error)
        end
      else
        Repo.rollback(:error)
      end
    end) do
      {:ok, board} ->
        broadcast socket, "created", %{:board => %{ id: board.id, name: board.name }}
      {:error, _} ->
        {:noreply, socket}
    end
    {:noreply, socket}
  end

  def handle_in("update", payload, socket) do
    "boards:" <> _board_id = socket.topic

    board = Repo.get(Board, _board_id)
    changeset = Board.changeset(board, %{ name: payload["name"] })

    if changeset.valid? do
      board = Repo.update(changeset)
      broadcast socket, "updated", %{:board => %{ id: board.id, name: board.name }}
    else
      {:noreply, socket}
    end
    {:noreply, socket}
  end

  def handle_in("delete", payload, socket) do
    "boards:" <> _board_id = socket.topic
    _user_id = socket.assigns.id

    board = Repo.get(Board, _board_id)
    usersboards = Repo.get_by(UsersBoards, user_id: _user_id, board_id: _board_id)

    if board && usersboards do
      case Repo.transaction(fn -> 
        case Repo.delete usersboards do
          {:error, _} ->
            Repo.rollback(:error)
          _ ->
            case Repo.delete board do
              {:error, _} ->
                Repo.rollback(:error)
              _ ->
                board.id
            end
        end
      end) do
        {:ok, board_id} ->
          broadcast socket, "deleted", %{:id => board_id}
        {:error, _} ->
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
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


  #############################
  ###  TODOに関するhandler  ###
  #############################

  def handle_in("todo:index", payload, socket) do
    "boards:" <> _board_id = socket.topic

    todos_query = Ecto.Query.from td in TODO,
      where: td.board_id == ^_board_id
    todos = Repo.all(todos_query)
    jtodo = Enum.map(todos,
      fn todo ->
        case TODO.encodeTODOtoJSON(todo.id) do
          {:ok, jtodo} ->
            jtodo
          {:error} ->
            %{}
        end
      end
    )
    broadcast socket, "todo:index", %{:todos => jtodo}
    {:noreply, socket}
  end

  def handle_in("todo:change", payload, socket) do
    case TODO.decodeJSONtoTODO(payload["todo"]) do
      {:ok, todo} ->
        {:ok, jtodo} = TODO.encodeTODOtoJSON(todo.id)
        broadcast socket, "todo:changed", %{:todo => jtodo}
      {:error} ->
        {:noreply, socket}
    end
    {:noreply, socket}
  end

  def handle_in("todo:create", payload, socket) do
    "boards:" <> _board_id = socket.topic

    board = Repo.get(Board, _board_id)
    if board do
      changeset = TODO.changeset(%TODO{}, %{ uid: Ecto.UUID.generate(), title: payload["title"], checked: false, content: "[]", board_id: board.id })
      if changeset.valid? do
        todo = Repo.insert(changeset)
        {:ok, jtodo} = TODO.encodeTODOtoJSON(todo.id)
        broadcast socket, "todo:created", %{:todo => jtodo}
      end
    end
    {:noreply, socket}
  end

  def handle_in("todo:delete", payload, socket) do
    "boards:" <> _board_id = socket.topic

    todo = Repo.get_by(TODO, uid:  payload["id"])
    if todo && todo.board_id == String.to_integer(_board_id) do
      case Repo.delete todo do
        {:error, _} ->
          {:noreply, socket}
        _ ->
          broadcast socket, "todo:deleted", %{:id => todo.uid}
      end
    end
    {:noreply, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
