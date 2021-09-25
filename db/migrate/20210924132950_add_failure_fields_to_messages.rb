class AddFailureFieldsToMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :failure_code, :smallint
    add_column :messages, :failure_message, :text
  end
end
