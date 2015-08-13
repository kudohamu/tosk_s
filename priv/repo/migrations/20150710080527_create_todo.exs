defmodule Tosk.Repo.Migrations.CreateTODO do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :uid, :string
      add :public, :boolean, default: false
      add :title, :string
      add :checked, :boolean, default: false
      add :content, :string
      add :board_id, :integer

      timestamps
    end
    create index(:todos, [:board_id])

  end
end
