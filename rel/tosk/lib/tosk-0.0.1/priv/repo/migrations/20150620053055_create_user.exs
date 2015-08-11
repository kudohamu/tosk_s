defmodule Tosk.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :icon, :string
      add :name, :string
      add :mail, :string
      add :hashed_password, :string
      add :provider, :string
      add :uid, :string

      timestamps
    end

  end
end
