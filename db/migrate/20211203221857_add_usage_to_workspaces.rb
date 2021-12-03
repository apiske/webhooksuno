class AddUsageToWorkspaces < ActiveRecord::Migration[6.1]
  def change
    add_column :workspaces, :capabilities, 'integer[]', default: []
  end
end
