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

  @required_fields ~w(icon name mail provider uid)
  @optional_fields ~w(hashed_password)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:name, ~r/^[0-9a-zA-Z_@\-]{4,30}$/)
    |> validate_format(:mail, ~r/^([\w\-\+_]+\.?[\w\-\+_]+)+@([a-z0-9\-]+\.[a-z]+)+$/)
    |> validate_unique(:mail, on: Tosk.Repo)
  end

  def get_user_icon_path do
    "./public/user_icons"
  end

  def valid_image_ext?(ext) do
    Enum.member?(["jpg", "jpeg", "png"], ext)
  end
end
