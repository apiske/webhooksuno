class RemoveTopicInternalDescription < ActiveRecord::Migration[6.1]
  def change
    remove_column :topics, :internal_description
  end
end
