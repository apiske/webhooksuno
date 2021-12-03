# frozen_string_literal: true

class ApiV1::TopicsController < ApiController
  before_action :fetch_topic, only: [:show, :update]
  before_action :process_input, only: [:update, :create]

  requires_workspace_capability :sender

  def create
    @topic = Topic.new
    @topic.attributes = @processor.values_for_model
    @topic.workspace = @workspace

    return unless with_common_record_checks do
      @topic.save!
    end

    render_single(@topic, :created)
  end

  def update
    @topic.attributes = @processor.values_for_model

    return unless with_common_record_checks do
      @topic.save!
    end

    render_single(@topic)
  end

  def show
    render_single(@topic)
  end

  def index
    render_collection_paginated(@workspace.topics)
  end

  private

  def fetch_topic
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @topic = @workspace.topics.find_by!(public_id: uuid)
  end

  def processor_entity_name
    :topic
  end
end
