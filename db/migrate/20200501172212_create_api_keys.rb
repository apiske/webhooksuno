class CreateApiKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :api_keys, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :name, :text, null: false
      t.column :secret, :bytea, null: false

      t.column :last_used_at, :timestamp

      t.column :expires_at, :timestamp
      t.column :deleted_at, :timestamp

      t.timestamps
    end

    add_index :api_keys, :workspace_id
    add_index :api_keys, :public_id
    add_index :api_keys, :name
    add_index :api_keys, [:name, :workspace_id], unique: true
    add_index :api_keys, :secret, unique: true
  end
end
