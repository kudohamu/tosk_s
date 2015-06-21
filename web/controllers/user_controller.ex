defmodule Tosk.UserController do
  use Tosk.Web, :controller

  alias Tosk.User

  plug :scrub_params, "user" when action in [:create, :update]
  plug :action

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    if (user_params["provider"] == "own") do
      ext = Enum.at(String.split(Enum.at(String.split(user_params["icon_data"], "data:image/"), 1), ";"), 0)
      if (User.valid_image_ext?(ext)) do
        image_b64 = Enum.at(String.split(user_params["icon_data"], "base64,"), 1)
        case {:ok, image_bin} = Base.decode64(image_b64) do
          {:ok, image_bin} ->
            icon_name = "#{Ecto.UUID.generate()}.#{ext}"
            case File.write(Path.join(User.get_user_icon_path, icon_name), image_bin, [:binary]) do
              :ok ->
                user_params = Map.put(user_params, "icon", Path.join(User.get_user_icon_path, icon_name))

                hashed_password = Comeonin.Bcrypt.hashpwsalt(user_params["password"])
                user_params = Map.put(user_params ,"hashed_password", hashed_password)

                user_params = Map.put(user_params, "uid", Ecto.UUID.generate())

                changeset = User.changeset(%User{}, user_params)
                if changeset.valid? && 7 < String.length(user_params["password"]) && user_params["password"] == user_params["password_confirmation"] do
                  user = Repo.insert(changeset)
                  token = Ecto.UUID.generate()
                  conn = conn |> fetch_session |> put_session(:token, Comeonin.Bcrypt.hashpwsalt(token))
                  render(conn, "create.json", %{id: user.id, token: token})
                else
                  # conn
                  # |> put_status(:unprocessable_entity)
                  # |> render(Tracoo.ChangesetView, "error.json", changeset: changeset)
                  if (changeset.errors[:mail] != nil) do
                    render(conn, "error.json", %{msg: "既に登録されているメールアドレスです"})
                  else
                    render(conn, "error.json", %{msg: "不正なデータが含まれています"})
                  end
                end
              {:error, _} ->
                # 画像が保存できなかった
                render(conn, "error.json", %{msg: "画像を保存できませんでした"})
            end
          {:error, _} ->
            # Base64からbinaryへの変換に失敗
            render(conn, "error.json", %{msg: "画像データが正しくない可能性があります"})
        end
      else
        # 画像の拡張子が不正
        render(conn, "error.json", %{msg: "不正な画像データです"})
      end
    else
      # providerの値が不正
      render(conn, "error.json", %{msg: "不正なデータが含まれています"})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, "show.json", user: user
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get(User, id)
    changeset = User.changeset(user, user_params)

    if changeset.valid? do
      user = Repo.update(changeset)
      render(conn, "show.json", user: user)
    else
      conn
      |> put_status(:unprocessable_entity)
      |> render(Tosk.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get(User, id)

    user = Repo.delete(user)
    render(conn, "show.json", user: user)
  end
end
