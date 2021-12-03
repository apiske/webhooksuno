# frozen_string_literal: true

class ApiV1::WebhookDefinitionsController < ApiController
  before_action :fetch_webhook_definition, only: [:show, :update]
  before_action :process_input, only: [:update, :create]

  requires_workspace_capability :sender

  def index
    render_collection_paginated(@workspace.webhook_definitions)
  end

  def show
    render_single(@webhook_definition)
  end

  def create
    @webhook_definition = WebhookDefinition.new
    @webhook_definition.attributes = @processor.values_for_model
    @webhook_definition.workspace = @workspace

    return unless with_common_record_checks do
      @webhook_definition.save!
    end

    render_single(@webhook_definition, :created)
  end

  def update
    @webhook_definition.attributes = @processor.values_for_model

    return unless with_common_record_checks do
      @webhook_definition.save!
    end

    render_single(@webhook_definition)
  end

  private

  def fetch_webhook_definition
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @webhook_definition = @workspace.webhook_definitions.find_by!(public_id: uuid)
  end

  def processor_entity_name
    :webhook_definition
  end
end
