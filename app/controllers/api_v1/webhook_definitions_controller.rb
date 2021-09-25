# frozen_string_literal: true

class ApiV1::WebhookDefinitionsController < ApiController
  class WebhookDefinitionContract < Wh::Contracts
    schema do
      optional(:name).value(:string)
      optional(:description).value(:string)
      optional(:retry_policy)
    end

    rule(:name).validate(:entity_name)
  end

  before_action :fetch_webhook_definition, only: [:show, :update]

  def index
    render_collection(@workspace.webhook_definitions.order(name: :asc).all)
  end

  def show
    render_single(@webhook_definition)
  end

  def create
    attributes = WebhookDefinitionContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    webhook_definition = WebhookDefinition.new
    set_webhook_definition_attributes(webhook_definition, attributes)
    webhook_definition.workspace = @workspace
    webhook_definition.save!

    render status: :created, json: {
      data: {
        id: webhook_definition.public_uuid
      }
    }
  end

  def update
    attributes = WebhookDefinitionContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    set_webhook_definition_attributes(@webhook_definition, attributes)
    @webhook_definition.save!

    render status: :created, json: {
      data: {
        id: @webhook_definition.public_uuid
      }
    }
  end

  private

  def fetch_webhook_definition
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @webhook_definition = @workspace.webhook_definitions.find_by!(public_id: uuid)
  end

  def set_webhook_definition_attributes(obj, data)
    if data.key?(:name)
      obj.name = data[:name]
    end

    if data.key?(:description)
      obj.description = data[:description]
    end

    if data.key?(:retry_policy)
      obj.retry_policy = data[:retry_policy]
    end
  end
end
