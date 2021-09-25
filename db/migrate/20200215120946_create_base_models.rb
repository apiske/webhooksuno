class CreateBaseModels < ActiveRecord::Migration[6.0]
  def change
    create_table :topics, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :name, :text, null: false
      t.column :internal_description, :text
      t.column :public_description, :text
      t.column :definition_id, :bigint, null: false
      t.timestamps
    end

    add_index :topics, :workspace_id
    add_index :topics, :public_id, unique: true
    add_index :topics, :definition_id
    add_index :topics, [:workspace_id, :name], unique: true

    create_table :webhook_definitions, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :name, :text, null: false
      t.column :description, :text
      t.column :retry_policy, :json, null: false, default: '{}'
      t.timestamps
    end

    add_index :webhook_definitions, :workspace_id
    add_index :webhook_definitions, :public_id, unique: true
    add_index :webhook_definitions, [:workspace_id, :name], unique: true

    create_table :tags, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :name, :string, null: false
      t.timestamps
    end

    add_index :tags, :workspace_id
    add_index :tags, :public_id, unique: true
    add_index :tags, [:workspace_id, :name], unique: true

    create_table :routers, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :tag_ids, 'bigint[]', default: '{}', null: false
      t.column :custom_attributes, :json
      t.column :allowed_topic_ids, 'bigint[]', default: '{}', null: false
      t.timestamps
    end

    add_index :routers, :workspace_id
    add_index :routers, :public_id, unique: true
    add_index :routers, :tag_ids, using: :gin

    create_table :subscriptions, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :name, :varchar, null: false
      t.column :destination_url, :varchar
      t.column :topic_ids, 'bigint[]', null: false, default: '{}'
      t.column :state, :integer, null: false
      t.column :destination_type, :integer, null: false
      t.column :key_id, :bigint, null: false
      t.column :router_id, :bigint, null: false
      t.timestamps
    end

    add_index :subscriptions, :workspace_id
    add_index :subscriptions, :router_id
    add_index :subscriptions, :public_id, unique: true
    add_index :subscriptions, [:workspace_id, :name], unique: true
    add_index :subscriptions, :topic_ids, using: :gin

    create_table :keys, id: :bigint do |t|
      t.column :workspace_id, :bigint, null: false
      t.column :public_id, 'bytea', null: false
      t.column :name, :varchar, null: false
      t.column :kind, :integer, null: false
      t.column :content, :bytea, null: true
      t.timestamps
    end

    add_index :keys, :workspace_id
    add_index :keys, :public_id, unique: true
    add_index :keys, [:workspace_id, :name], unique: true

  end
end
