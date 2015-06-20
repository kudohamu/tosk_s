defmodule Tosk.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :icon, :string
      add :name, :string
      add :mail, :string
      add :hased_password, :string
      add :provider, :string

      timestamps
    end

  end
end
