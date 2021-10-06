class FixDefinitionRetryFields < ActiveRecord::Migration[6.1]
  def change
    remove_column :webhook_definitions, :retry_policy

    add_column :webhook_definitions, :retry_wait_factor, :integer, null: false
    add_column :webhook_definitions, :retry_max_retries, :integer, null: false
  end
end
