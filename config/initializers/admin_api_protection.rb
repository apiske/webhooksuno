# frozen_string_literal: true

if Comff.get_bool!("admin.enabled")
  has_error = false

  def err(msg)
    Rails.logger.error(msg)
    puts("\nPANIC: #{msg}\n")
  end

  if Comff.get_str("admin.allow_from").empty?
    err("The configuration admin.allow_from cannot be empty. " +
      "See https://webhooks.uno/docs/installation for possible values. Aborting bootstrap.")
    has_error = true
  end

  if Comff.get_str("admin.auth_token").empty?
    err("The configuration admin.auth_token cannot be empty. " +
      "When admin is enabled, an authentication token must be present. Aborting bootstrap.")
    has_error = true
  end

  if has_error
    err("The admin API configuration was left unsafe. Please fix the errors above to continue." +
      " The boot process will now be aborted.")

    exit(1)
  end

  allowed_ips = Comff.get_str!("admin.allow_from").split(',').map do |mask|
    mask = mask.strip
    IPAddr.new(mask)
  end

  Rack::Attack.safelist("Admin API safelist") do |req|
    next true unless req.path.start_with?('/admin/')

    allowed_ips.any? { |mask| mask.include?(req.ip) }
  end

  Rack::Attack.blocklist("Admin API blocklist") do |req|
    next false unless req.path.start_with?('/admin/')

    true
  end
end
