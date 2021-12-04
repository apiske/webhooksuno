# frozen_string_literal: true

class Provisioner::ReceiverWorkspaceProvisioner
  attr_reader :workspace
  attr_reader :api_key
  attr_reader :default_key

  def initialize(workspace_name:)
    @workspace_name = workspace_name
    @entities = []
  end

  def run
    create_entities
    save_entities!
  end

  def save_entities!
    ActiveRecord::Base.transaction do
      @entities.each(&:save!)
    end
  end

  def create_entities
    create_workspace
    create_default_api_key
  end

  def create_workspace
    @workspace = Workspace.new(name: @workspace_name)
    @workspace.set_capability(:receiver, true)

    @entities << @workspace
  end

  def create_default_api_key
    @api_key = ApiKey.new(name: 'default', workspace: @workspace)
    @api_key.generate_secret!

    @entities << @api_key
  end
end
