# frozen_string_literal: true

class ApiV1::RoutersController < ApiController
  class RouterContract < Wh::Contracts
    schema do
      optional(:name).value(:string)
      optional(:tags).array(:string)
      optional(:allowed_topics).array(:string)
      optional(:custom_attributes)
    end

    rule(:name).validate(:entity_name)
    rule(:tags).validate(:uuid_or_names)
    rule(:allowed_topics).validate(:uuid_or_names)
    rule(:custom_attributes).validate(:custom_json)
  end

  before_action :fetch_router, only: [:show, :update]

  def index
    render_collection(@workspace.routers.order(name: :asc).all)
  end

  def show
    render_single(@router)
  end

  def create
    attributes = RouterContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    router = Router.new
    set_router_attributes(router, attributes)
    router.workspace = @workspace
    router.save!

    render status: :created, json: {
      data: {
        id: router.public_uuid
      }
    }
  end

  def update
    attributes = RouterContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    set_router_attributes(@router, attributes)
    @router.save!

    head 204
  end

  private

  def fetch_router
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @router = @workspace.routers.find_by!(public_id: uuid)
  end

  def set_router_attributes(router, data)
    if data.key?(:tags)
      tags_query = ModelUtil.terms_query(Tag, data[:tags])
      tag_ids = @workspace.tags.where(tags_query).select(:id).map(&:id)
      router.tag_ids = tag_ids
    end

    if data.key?(:custom_attributes)
      router.custom_attributes = data[:custom_attributes]
    end

    if data.key?(:allowed_topics)
      topics_query = ModelUtil.terms_query(Topic, data[:allowed_topics])
      topic_ids = @workspace.topics.where(topics_query).select(:id).map(&:id)
      router.allowed_topic_ids = topic_ids
    end

    router.name = data[:name]
  end
end
