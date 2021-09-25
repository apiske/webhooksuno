# frozen_string_literal: true

class ApiV1::BindingRequestsController < ApiController
  USE_TYPES = {
    "once" => 1,
    "unlimited" => 2,
    "once_per_workspace" => 3
  }.freeze

  class BindingRequestContract < Wh::Contracts
    schema do
      optional(:router).value(:string)
      optional(:use_type).value(:string)
      # optional(:allowed_workspace_ids).array(:string)
      optional(:message).value(:string)
    end

    rule(:router).validate(:uuid_or_name)
    # rule(:allowed_workspace_ids).validate(:uuid_or_names)
    rule(:use_type) do
      next if value.nil?
      unless USE_TYPES.key?(value)
        all_types = USE_TYPES.keys.join(", ")
        key.failure("must be one of (#{all_types})")
      end
    end
  end

  before_action :fetch_binding_request, only: [:show, :update]

  def index
    render_collection(@workspace.binding_requests.order(created_at: :asc).all)
  end

  def show
    render_single(@binding_request)
  end

  def create
    attributes = BindingRequestContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    binding_request = BindingRequest.new
    set_binding_request_attributes(binding_request, attributes)
    binding_request.workspace = @workspace
    binding_request.save!

    render status: :created, json: {
      data: {
        id: binding_request.public_uuid
      }
    }
  end

  def update
    attributes = KeyContract.new.call(body_obj["data"].symbolize_keys)
    return fail_validation!(attributes.errors) if attributes.failure?

    set_binding_request_attributes(@binding_request, attributes)
    @binding_request.save!

    head 204
  end

  private

  def fetch_binding_request
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @binding_request = @workspace.binding_requests.find_by!(public_id: uuid)
  end

  def set_binding_request_attributes(binding_request, data)
    if data.key?(:router)
      routers_query = ModelUtil.terms_query(Router, [data[:router]])
      router = @workspace.routers.where(routers_query).first!
      binding_request.router = router
    end

    if data.key?(:message)
      binding_request.message = data[:message]
    end

    if data.key?(:use_type)
      binding_request.use_type = USE_TYPES.fetch(data[:use_type])
    end

    # TODO: implement for "once_per_workspace"
    # if data.key?(:allowed_workspace_ids)
    #   key.kind = KEY_KINDS.fetch(data[:kind])
    # end
  end
end
