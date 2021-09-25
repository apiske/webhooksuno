class AddMessageToBindingRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :binding_requests, :message, :text
  end
end
