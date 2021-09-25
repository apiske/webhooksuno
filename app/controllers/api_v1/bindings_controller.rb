# frozen_string_literal: true

class ApiV1::BindingsController < ApiController
  skip_before_action :check_login, only: [:check]

  before_action :fetch_binding_request_from_code, only: [:check, :activate]
  before_action :fetch_binding_request_from_id, only: [:index_topics]

  def check
    # TODO: check whether it is actually valid or not

    render json: {
      data: {
        status: "valid",
        message: @binding_request.message
      }
    }, status: 200
  end

  def activate
    existing_rb = @workspace.receiver_bindings
      .find_by(binding_request_id: @binding_request.id)

    # TODO: fix race condition
    if existing_rb.present?
      return render json: {
        data: {
          status: "used",
          message: "This binding has already been activated",
          binding_id: @binding_request.public_uuid
        }
      }, status: 409
    end

    ri = ReceiverBinding.new
    ri.workspace = @workspace
    ri.binding_request = @binding_request
    ri.router_id = @binding_request.router_id
    ri.state = ReceiverBinding::STATE_ENABLED

    ri.save!

    render json: {
      data: {
        status: "valid",
        binding_id: @binding_request.public_uuid
      }
    }, status: 200
  end

  def index_topics
    rb_workspace = @binding_request.router.workspace
    topic_names = rb_workspace.topics.all

    output_data = topic_names.map do |topic|
      {
        id: topic.public_uuid,
        name: topic.name,
        description: topic.public_description
      }
    end

    render json: {
      data: output_data
    }, status: 200
  end

  def list_bindings
    bindings = @workspace
      .receiver_bindings
      .eager_load(receiver_bindings: [ :binding_request ])
      .where.not(receiver_bindings: { deleted_at: nil })

    render_collection(@workspace.subscriptions.order(name: :asc).all)
  end

  private

  def fetch_binding_request_from_code
    code = params[:code]
    uuid = UuidUtil.uuid_s_to_bin(code)
    @binding_request = BindingRequest.find_by!(public_id: uuid)
  end

  def fetch_binding_request_from_id
    code = params[:binding_id]
    uuid = UuidUtil.uuid_s_to_bin(code)
    @binding_request = BindingRequest
      .eager_load(router: [:workspace])
      .find_by!(public_id: uuid)
  end
end
