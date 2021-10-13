# frozen_string_literal: true

class ApiV1::RoutersController < ApiController
  before_action :fetch_router, only: [:show, :update]
  before_action :process_input, only: [:update, :create]

  def index
    render_collection(@workspace.routers.order(name: :asc).all)
  end

  def show
    render_single(@router)
  end

  def create
    @router = Router.new
    @router.attributes = @processor.values_for_model
    @router.workspace = @workspace

    return unless with_common_record_checks do
      @router.save!
    end

    render_single(@router, :created)
  end

  def update
    @router.attributes = @processor.values_for_model

    return unless with_common_record_checks do
      @router.save!
    end

    render_single(@router)
  end

  private

  def fetch_router
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @router = @workspace.routers.find_by!(public_id: uuid)
  end

  def processor_entity_name
    :router
  end
end
