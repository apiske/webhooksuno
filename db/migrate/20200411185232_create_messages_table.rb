class CreateMessagesTable < ActiveRecord::Migration[6.0]
  def change
    create_table :messages, id: :bytea do |t|
      t.column :sender_workspace_id, :bigint, null: false
      t.column :receiver_workspace_id, :bigint, null: false
      t.column :delivery_request_id, :bigint, null: false

      t.column :payload, :bytea
      t.column :request_headers, :json
      t.column :response_body, :bytea
      t.column :response_headers, :json
      t.column :response_status_code, :integer

      t.column :state, :smallint, null: false
      t.column :deliver_after, :timestamp

      t.column :delivered_at, :timestamp
      t.column :delivery_tentatives_at, 'timestamp[]'

      t.timestamps
    end
  end
end
