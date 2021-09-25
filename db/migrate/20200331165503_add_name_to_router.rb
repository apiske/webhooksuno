class AddNameToRouter < ActiveRecord::Migration[6.0]
  def change
    add_column :routers, :name, :varchar, null: false
    add_index :routers, [:workspace_id, :name], unique: true
  end
end
