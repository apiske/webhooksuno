class CreateWorkspace < ActiveRecord::Migration[6.0]
  def change
    create_table :workspaces, id: :bigint do |t|
      t.column :public_id, :bytea, null: false
      t.column :name, :varchar, null: false

      t.timestamps
    end

    add_index :workspaces, :public_id, unique: true
    add_index :workspaces, [:name], unique: true
  end
end
