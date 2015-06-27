defmodule Tosk.User do
  use Tosk.Web, :model

  schema "users" do
    field :icon, :string
    field :name, :string
    field :mail, :string
    field :hashed_password, :string
    field :provider, :string
    field :uid, :string

    timestamps
  end

  @required_fields ~w(icon name mail provider)
  @optional_fields ~w(hashed_password uid)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:name, ~r/^[0-9a-zA-Z_@\-]{4,30}$/)
    |> validate_format(:icon, ~r/^.+\.(png|jpg|jpeg)$/)
    |> validate_format(:mail, ~r/^([\w\-\+_]+\.?[\w\-\+_]+)+@([a-z0-9\-]+\.[a-z]+)+$/)
    |> validate_unique(:mail, on: Tosk.Repo)
    |> validate_format(:provider, ~r/^(own|twitter|facebook)$/)
  end

  def get_user_icon_path do
    "./public/user_icons"
  end

  def valid_image_ext?(ext) do
    Enum.member?(["jpg", "jpeg", "png"], ext)
  end

  def upload_icon(icon_data) do
    ext = Enum.at(String.split(Enum.at(String.split(icon_data, "data:image/"), 1), ";"), 0)
    if (valid_image_ext?(ext)) do
      image_b64 = Enum.at(String.split(icon_data, "base64,"), 1)
      case {:ok, image_bin} = Base.decode64(image_b64) do
        {:ok, image_bin} ->
          icon_name = "#{Ecto.UUID.generate()}.#{ext}"
          unless File.exists?(get_user_icon_path) do
            File.mkdir_p(get_user_icon_path)
          end
          case File.write(Path.join([get_user_icon_path, icon_name]), image_bin, [:binary]) do
            :ok ->
              {:ok, icon_name}
            {:error, _} ->
              # 画像が保存できなかった
              {:err, :cannot_save_icon}
          end
        {:error, _} ->
          # Base64からbinaryへの変換に失敗
          {:err, :invalid_data}
      end
    else
      # 画像の拡張子が不正
      {:err, :invalid_data}
    end
  end
end
