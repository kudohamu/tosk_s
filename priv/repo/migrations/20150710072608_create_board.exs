defmodule Tosk.Repo.Migrations.CreateBoard do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :name, :string
      add :category, :integer

      timestamps
    end

  end
end
