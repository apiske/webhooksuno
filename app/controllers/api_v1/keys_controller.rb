# frozen_string_literal: true

class ApiV1::KeysController < ApiController
  before_action :fetch_key, only: [:show, :update]
  before_action :process_input, only: [:update, :create]

  def index
    render_collection(@workspace.keys.order(name: :asc).all)
  end

  def show
    render_single(@key)
  end

  def create
    @key = Key.new
    @key.attributes = @processor.values_for_model
    @key.workspace = @workspace

    return unless with_common_record_checks do
      @key.save!
    end

    render_single(@key, :created)
  end

  def update
    return if fail_on_invalid_body_payload!

    processor = Apidef::Processor.new(:update, api_ctx, :key, ref_solver)
    processor.process_input(body_obj["data"])

    return if fail_on_invalid_processor!(processor)

    key = Key.new
    key.attributes = processor.values_for_model
    key.workspace = @workspace

    return unless with_common_record_checks do
      key.save!
    end

    render status: :created, json: {
      data: {
        id: key.public_uuid
      }
    }
  end

  private

  def fetch_key
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @key = @workspace.keys.find_by!(public_id: uuid)
  end

  def processor_entity_name
    :key
  end
end
