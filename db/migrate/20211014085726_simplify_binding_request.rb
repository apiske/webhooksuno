class SimplifyBindingRequest < ActiveRecord::Migration[6.1]
  def change
    remove_column :binding_requests, :use_type
    remove_column :binding_requests, :allowed_workspace_ids
  end
end
