defmodule Tosk.Repo.Migrations.CreateUsersBoards do
  use Ecto.Migration

  def change do
    create table(:usersboards) do
      add :board_id, :integer
      add :user_id, :integer

      timestamps
    end
    create index(:usersboards, [:board_id])
    create index(:usersboards, [:user_id])

  end
end
