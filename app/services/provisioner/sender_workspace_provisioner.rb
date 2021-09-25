# frozen_string_literal: true

class Provisioner::SenderWorkspaceProvisioner
  attr_reader :workspace
  attr_reader :public_tag
  attr_reader :default_tag
  attr_reader :webhook_definition
  attr_reader :api_key

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
    create_default_tags
    create_default_definition
    create_default_api_key
  end

  def create_workspace
    @workspace = Workspace.new(name: @workspace_name)

    @entities << @workspace
  end

  def create_default_tags
    @default_tag = Tag.new(workspace: @workspace, name: 'default')

    @entities += [@default_tag]
  end

  def create_default_definition
    @webhook_definition = WebhookDefinition.new(workspace: @workspace,
      name: 'default', retry_policy: {})

    @entities << @webhook_definition
  end

  def create_default_api_key
    @api_key = ApiKey.new(name: 'default', workspace: @workspace)
    @api_key.generate_secret!

    @entities << @api_key
  end
end
