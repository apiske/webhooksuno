# frozen_string_literal: true

class ApiAdmin::WorkspacesController < AdminApiController
  before_action :fetch_workspace, only: [:show, :rotate_api_key]

  def index
    workspaces = Workspace.eager_load(:api_keys).order(id: :asc).map do |ws|
      workspace_for_serialization(ws)
    end

    render json: { data: workspaces }
  end

  def create
    data = body_obj['data']
    errors = []

    type = data['type']
    if !%w(sender receiver).include?(type)
      errors << "type attribute must be either sender or receiver"

      return render_errors(errors)
    end

    provisioner_class = case type
      when "receiver"
        Provisioner::ReceiverWorkspaceProvisioner
      when "sender"
        Provisioner::SenderWorkspaceProvisioner
      end

    provisioner = provisioner_class.new(workspace_name: data['name'])
    provisioner.run

    render status: :created, json: {
      data: {
        id: provisioner.workspace.public_uuid,
        name: provisioner.workspace.name,
        api_key: provisioner.api_key.key
      }
    }
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
        secret: new_api_key.key
      }
    }
  end

  private

  def render_errors(e)
    render status: :unprocessable_entity, json: { errors: e }
  end

  def workspace_for_serialization(ws)
    api_key = ws.api_keys.order(id: :desc).limit(1).where(expires_at: nil, deleted_at: nil).first

    caps = ws.capabilities.map do |cap_id|
      Workspace::REVERSE_CAPABILITIES[cap_id]
    end

    {
      id: ws.public_uuid,
      name: ws.name,
      api_key_created_at: api_key&.created_at,
      capabilities: caps,
      created_at: ws.created_at
    }
  end

  def fetch_workspace
    uuid = UuidUtil.uuid_s_to_bin(params[:id])
    @workspace = Workspace.eager_load(:api_keys).find_by!(public_id: uuid)
  end
end
