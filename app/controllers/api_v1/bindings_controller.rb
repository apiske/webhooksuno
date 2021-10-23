# frozen_string_literal: true

class ApiV1::BindingsController < ApiController
  before_action :fetch_router, only: [:create]
  before_action :fetch_binding, only: [:topics, :show]

  def create
    existing_rb = @workspace.receiver_bindings
      .find_by(router_id: @router.id)

    # TODO: fix race condition [#179782548]
    if existing_rb.present?
      return render_single(existing_rb, :conflict)
    end

    ri = ReceiverBinding.new
    ri.workspace = @workspace
    ri.router_id = @router.id
    ri.state = ReceiverBinding::STATE_ENABLED
    ri.name = body_obj["data"].fetch("name")

    return unless with_common_record_checks do
      ri.save!
    end

    render_single(ri, :created)
  end

  def topics
    rb_workspace = @router.workspace
    topic_names = rb_workspace
      .topics
      .where(id: @router.allowed_topic_ids)
      .all

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

  def show
    render_single(@receiver_binding)
  end

  def index
    bindings = @workspace
      .receiver_bindings
      .where(receiver_bindings: { deleted_at: nil })

    render_collection(bindings)
  end

  private

  def fetch_binding
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @receiver_binding = @workspace
      .receiver_bindings
      .eager_load(:router)
      .find_by!(public_id: uuid)

    @router = @receiver_binding.router
  end

  def fetch_router
    uuid = UuidUtil.uuid_s_to_bin(body_obj.dig("data", "router_id"))
    @router = Router.find_by!(public_id: uuid)
  end
end
