# frozen_string_literal: true

class ApiV1::TagsController < ApiController
  class TagContract < Wh::Contracts
    schema do
      optional(:name).value(:string)
    end

    rule(:name).validate(:entity_name)
  end

  before_action :fetch_tag, only: [:show]

  def index
    render_collection(@workspace.tags.order(name: :asc).all)
  end

  def show
    render_single(@tag)
  end

  def create
    attributes = TagContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    tag = Tag.new
    tag.name = attributes[:name]
    tag.workspace = @workspace
    tag.save!

    render status: :created, json: {
      data: {
        id: tag.public_uuid
      }
    }
  end

  private

  def fetch_tag
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @tag = @workspace.tags.find_by!(public_id: uuid)
  end
end
