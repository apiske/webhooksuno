class AddSecondRoundModels < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :receiver_binding_id, :bigint
    add_index :subscriptions, :receiver_binding_id

    create_table :binding_requests, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :router_id, :bigint, null: false
      t.column :use_type, :smallint, null: false
      t.column :allowed_workspace_ids, 'bigint[]'
      t.timestamps
    end

    add_index :binding_requests, :workspace_id
    add_index :binding_requests, :public_id, unique: true

    create_table :receiver_bindings, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :binding_request_id, :bigint, null: false
      t.column :router_id, :bigint, null: false
      t.column :state, :smallint, null: false
      t.column :deleted_at, 'timestamp'
      t.timestamps
    end

    add_index :receiver_bindings, :workspace_id
    add_index :receiver_bindings, :binding_request_id
    add_index :receiver_bindings, :router_id
    add_index :receiver_bindings, [:binding_request_id, :router_id], unique: true, name: 'idx_recv_intg_reqid_rtrid'
    add_index :receiver_bindings, '(deleted_at IS NULL)', name: 'idx_rcv_intg_del'

    create_table :delivery_requests, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :topic_id, :bigint, null: false
      t.column :topic_name, :varchar, null: false

      t.column :request_body, :text
      t.column :request_headers, :text
      t.column :tag_ids, 'bigint[]'
      t.column :payload, :text, null: false
      t.column :extra_fields, :text
      t.column :state, :smallint, null: false
      t.column :deliver_after, 'timestamp'

      t.timestamps
    end

    add_index :delivery_requests, :workspace_id
    add_index :delivery_requests, :public_id, unique: true
    add_index :delivery_requests, :topic_id
    add_index :delivery_requests, :state
    add_index :delivery_requests, :deliver_after
  end
end
