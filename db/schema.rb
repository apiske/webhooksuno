# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_03_221857) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.binary "public_id", null: false
    t.text "name", null: false
    t.text "key_id", null: false
    t.binary "key_secret", null: false
    t.binary "key_salt", null: false
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key_id"], name: "index_api_keys_on_key_id", unique: true
    t.index ["name", "workspace_id"], name: "index_api_keys_on_name_and_workspace_id", unique: true
    t.index ["name"], name: "index_api_keys_on_name"
    t.index ["public_id"], name: "index_api_keys_on_public_id"
    t.index ["workspace_id"], name: "index_api_keys_on_workspace_id"
  end

  create_table "delivery_requests", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.binary "public_id", null: false
    t.bigint "topic_id", null: false
    t.string "topic_name", null: false
    t.text "request_body"
    t.text "request_headers"
    t.integer "state", limit: 2, null: false
    t.datetime "deliver_after"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.binary "payload"
    t.jsonb "extra_fields"
    t.bigint "include_tag_ids", array: true
    t.bigint "exclude_tag_ids", array: true
    t.integer "payload_datatype", limit: 2, null: false
    t.index ["deliver_after"], name: "index_delivery_requests_on_deliver_after"
    t.index ["public_id"], name: "index_delivery_requests_on_public_id", unique: true
    t.index ["state"], name: "index_delivery_requests_on_state"
    t.index ["topic_id"], name: "index_delivery_requests_on_topic_id"
    t.index ["workspace_id"], name: "index_delivery_requests_on_workspace_id"
  end

  create_table "keys", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.binary "public_id", null: false
    t.string "name", null: false
    t.integer "kind", null: false
    t.binary "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["public_id"], name: "index_keys_on_public_id", unique: true
    t.index ["workspace_id", "name"], name: "index_keys_on_workspace_id_and_name", unique: true
    t.index ["workspace_id"], name: "index_keys_on_workspace_id"
  end

  create_table "messages", id: :binary, force: :cascade do |t|
    t.bigint "sender_workspace_id", null: false
    t.bigint "receiver_workspace_id", null: false
    t.bigint "delivery_request_id", null: false
    t.binary "payload"
    t.json "request_headers"
    t.binary "response_body"
    t.json "response_headers"
    t.integer "response_status_code"
    t.integer "state", limit: 2, null: false
    t.datetime "deliver_after"
    t.datetime "delivered_at"
    t.datetime "delivery_tentatives_at", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "failure_code", limit: 2
    t.text "failure_message"
    t.bigint "definition_id", null: false
  end

  create_table "receiver_bindings", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "router_id", null: false
    t.integer "state", limit: 2, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.binary "public_id", null: false
    t.text "name", null: false
    t.index "((deleted_at IS NULL))", name: "idx_rcv_intg_del"
    t.index ["name"], name: "index_receiver_bindings_on_name"
    t.index ["router_id"], name: "index_receiver_bindings_on_router_id"
    t.index ["workspace_id", "name"], name: "idx_bindings_workspace_and_name", unique: true
    t.index ["workspace_id"], name: "index_receiver_bindings_on_workspace_id"
  end

  create_table "routers", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.binary "public_id", null: false
    t.bigint "tag_ids", default: [], null: false, array: true
    t.json "custom_attributes"
    t.bigint "allowed_topic_ids", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.index ["public_id"], name: "index_routers_on_public_id", unique: true
    t.index ["tag_ids"], name: "index_routers_on_tag_ids", using: :gin
    t.index ["workspace_id", "name"], name: "index_routers_on_workspace_id_and_name", unique: true
    t.index ["workspace_id"], name: "index_routers_on_workspace_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.binary "public_id", null: false
    t.string "name", null: false
    t.string "destination_url"
    t.bigint "topic_ids", default: [], null: false, array: true
    t.integer "state", null: false
    t.integer "destination_type", null: false
    t.bigint "key_id", null: false
    t.bigint "router_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "receiver_binding_id"
    t.index ["public_id"], name: "index_subscriptions_on_public_id", unique: true
    t.index ["receiver_binding_id"], name: "index_subscriptions_on_receiver_binding_id"
    t.index ["router_id"], name: "index_subscriptions_on_router_id"
    t.index ["topic_ids"], name: "index_subscriptions_on_topic_ids", using: :gin
    t.index ["workspace_id", "name"], name: "index_subscriptions_on_workspace_id_and_name", unique: true
    t.index ["workspace_id"], name: "index_subscriptions_on_workspace_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.binary "public_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["public_id"], name: "index_tags_on_public_id", unique: true
    t.index ["workspace_id", "name"], name: "index_tags_on_workspace_id_and_name", unique: true
    t.index ["workspace_id"], name: "index_tags_on_workspace_id"
  end

  create_table "topics", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.binary "public_id", null: false
    t.text "name", null: false
    t.text "public_description"
    t.bigint "definition_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["definition_id"], name: "index_topics_on_definition_id"
    t.index ["public_id"], name: "index_topics_on_public_id", unique: true
    t.index ["workspace_id", "name"], name: "index_topics_on_workspace_id_and_name", unique: true
    t.index ["workspace_id"], name: "index_topics_on_workspace_id"
  end

  create_table "webhook_definitions", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.binary "public_id", null: false
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "retry_wait_factor", null: false
    t.integer "retry_max_retries", null: false
    t.index ["public_id"], name: "index_webhook_definitions_on_public_id", unique: true
    t.index ["workspace_id", "name"], name: "index_webhook_definitions_on_workspace_id_and_name", unique: true
    t.index ["workspace_id"], name: "index_webhook_definitions_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.binary "public_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "capabilities", default: [], array: true
    t.index ["name"], name: "index_workspaces_on_name", unique: true
    t.index ["public_id"], name: "index_workspaces_on_public_id", unique: true
  end

end
