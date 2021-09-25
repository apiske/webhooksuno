
namespace :uno do
  desc 'Creates a new sender Workspace'
  task createsender: :environment do
    workspace_name = ENV['UNO_WORKSPACE_NAME']
    if !workspace_name || workspace_name.empty?
      puts("You must specificy the workspace name to be created through the UNO_WORKSPACE_NAME environment variable.")
      exit(1)
      return
    end

    if Workspace.where(name: workspace_name).exists?
      puts("Workspace with name '#{workspace_name}' already exists! Workspace names must be unique. Aborting.")
      exit(1)
      return
    end

    puts("Creating sender workspace '#{workspace_name}'")

    provisioner = Provisioner::SenderWorkspaceProvisioner.new(workspace_name: workspace_name)
    provisioner.run

    api_key = Base64.urlsafe_encode64(provisioner.api_key.secret)

    puts "Workspace #{workspace_name} created with ID #{provisioner.workspace.public_uuid}!"
    puts "Use the following API key to access it: #{api_key}"
  end

  desc 'Creates a new receiver Workspace'
  task createreceiver: :environment do
    workspace_name = ENV['UNO_WORKSPACE_NAME']
    if !workspace_name || workspace_name.empty?
      puts("You must specificy the workspace name to be created through the UNO_WORKSPACE_NAME environment variable.")
      exit(1)
      return
    end

    if Workspace.where(name: workspace_name).exists?
      puts("Workspace with name '#{workspace_name}' already exists! Workspace names must be unique. Aborting.")
      exit(1)
      return
    end

    puts("Creating receiver workspace '#{workspace_name}'")

    provisioner = Provisioner::ReceiverWorkspaceProvisioner.new(workspace_name: workspace_name)
    provisioner.run

    api_key = Base64.urlsafe_encode64(provisioner.api_key.secret)

    puts "Workspace #{workspace_name} created with ID #{provisioner.workspace.public_uuid}!"
    puts "Use the following API key to access it: #{api_key}"
  end
end
