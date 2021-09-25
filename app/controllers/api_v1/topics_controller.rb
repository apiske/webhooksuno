# frozen_string_literal: true

class ApiV1::TopicsController < ApiController
  class TopicContract < Wh::Contracts
    schema do
      optional(:name).value(:string)
      optional(:internal_description).value(:string)
      optional(:public_description).value(:string)
      required(:webhook_definition)
    end

    rule(:name).validate(:entity_name)
    rule(:webhook_definition).validate(:uuid_or_name)
  end

  before_action :fetch_topic, only: [:show, :update]
  before_action :validate_attributes, only: [:create, :update]

  def create
    topic = Topic.new

    set_topic_attributes(topic, @attributes)
    topic.workspace = @workspace

    topic.save!

    render status: :created, json: {
      data: {
        id: topic.public_uuid
      }
    }
  end

  def update
    set_topic_attributes(@topic, @attributes)
    @topic.save

    head :no_content
  end

  def show
    render_single(@topic)
  end

  def index
    render_collection(@workspace.topics.all)
  end

  private

  def set_topic_attributes(topic, data)
    if data.key?(:name)
      topic.name = data[:name]
    end

    if data.key?(:internal_description)
      topic.internal_description = data[:internal_description]
    end

    if data.key?(:public_description)
      topic.public_description = data[:public_description]
    end

    if data.key?(:webhook_definition)
      definition_query = ModelUtil.terms_query(WebhookDefinition, [data[:webhook_definition]])
      definition = @workspace.webhook_definitions.where(definition_query).first!
      topic.definition = definition
    end
  end

  def validate_attributes
    @attributes = TopicContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(@attributes.errors) if @attributes.failure?
  end

  def fetch_topic
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @topic = @workspace.topics.find_by!(public_id: uuid)
  end
end
