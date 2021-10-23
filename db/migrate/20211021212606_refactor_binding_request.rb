class RefactorBindingRequest < ActiveRecord::Migration[6.1]
  def change
    drop_table :binding_requests
    remove_column :receiver_bindings, :binding_request_id
    add_column :receiver_bindings, :public_id, :bytea, null: false

    add_column :receiver_bindings, :name, :text, null: false
    add_index :receiver_bindings, :name
    add_index :receiver_bindings, [:workspace_id, :name], unique: true, name: 'idx_bindings_workspace_and_name'
  end
end
