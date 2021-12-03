# frozen_string_literal: true

class ApiV1::TagsController < ApiController
  before_action :fetch_tag, only: [:show, :update]
  before_action :process_input, only: [:update, :create]

  requires_workspace_capability :sender

  def index
    render_collection_paginated(@workspace.tags)
  end

  def show
    render_single(@tag)
  end

  def create
    @tag = Tag.new
    @tag.attributes = @processor.values_for_model
    @tag.workspace = @workspace

    return unless with_common_record_checks do
      @tag.save!
    end

    render_single(@tag, :created)
  end

  def update
    @tag.attributes = @processor.values_for_model

    return unless with_common_record_checks do
      @tag.save!
    end

    render_single(@tag)
  end

  private

  def fetch_tag
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @tag = @workspace.tags.find_by!(public_id: uuid)
  end

  def processor_entity_name
    :tag
  end
end
