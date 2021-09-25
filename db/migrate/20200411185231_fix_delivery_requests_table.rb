class FixDeliveryRequestsTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :delivery_requests, :payload
    add_column :delivery_requests, :payload, :bytea

    remove_column :delivery_requests, :extra_fields
    add_column :delivery_requests, :extra_fields, :jsonb

    remove_column :delivery_requests, :tag_ids
    add_column :delivery_requests, :include_tag_ids, 'bigint[]'
    add_column :delivery_requests, :exclude_tag_ids, 'bigint[]'

    add_column :delivery_requests, :payload_datatype, :smallint, null: false
  end
end
