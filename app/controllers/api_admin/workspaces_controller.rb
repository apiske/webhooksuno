# frozen_string_literal: true

class ApiAdmin::WorkspacesController < AdminApiController
  before_action :fetch_workspace, only: [:show, :rotate_api_key]

  def index
    workspaces = Workspace.eager_load(:api_keys).order(id: :asc).map do |ws|
      workspace_for_serialization(ws)
    end

    render json: { data: workspaces }
  end

  def show
    render json: { data: workspace_for_serialization(@workspace) }
  end

  def rotate_api_key
    expire_in = params[:expire_in_days]
    expire_in = 10 if expire_in == nil

    expires_at = Integer(expire_in).days.from_now

    to_delete_api_keys = @workspace.api_keys.where('expires_at < ?', Time.now).to_a
    other_api_keys = @workspace.api_keys.where(expires_at: nil, deleted_at: nil).to_a
    new_api_key = ApiKey.new(name: SecureRandom.uuid, workspace: @workspace)
    new_api_key.generate_secret!

    ActiveRecord::Base.transaction do
      to_delete_api_keys.each(&:destroy!)
      other_api_keys.each { |key| key.update!(expires_at: expires_at) }
      new_api_key.save!
    end

    render json: {
      data: {
        secret: Base64.strict_encode64(new_api_key.secret)
      }
    }
  end

  private

  def workspace_for_serialization(ws)
    api_key = ws.api_keys.order(id: :desc).limit(1).where(expires_at: nil, deleted_at: nil).first

    {
      id: ws.public_uuid,
      name: ws.name,
      api_key_created_at: api_key&.created_at,
      created_at: ws.created_at
    }
  end

  def fetch_workspace
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @workspace = Workspace.eager_load(:api_keys).find_by!(public_id: uuid)
  end
end
