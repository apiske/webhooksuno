class AddDefinitionIdToMessage < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :definition_id, :bigint, null: false
  end
end
