# frozen_string_literal: true

module AdminAuth
  def authorize_admin!
    auth_header = request.headers["HTTP_AUTHORIZATION"]

    # This should never be false because if admin.enabled==false then the
    # route won't be created. But will let this here as a paranoid safety net.
    admin_enabled = Comff.get_bool!("admin.enabled")

    if admin_enabled && auth_header&.start_with?("Bearer ")
      token = auth_header[7..-1]
      expected_token = Comff.get_str!("admin.auth_token")

      return true if safe_compare_tokens(token, expected_token)
    end

    render status: 403, json: { error: {code: "unauthorized"} }
  end

  private

  def safe_compare_tokens(a, b)
    return false if a.length != b.length

    b_bytes = b.bytes

    r = 0
    a.each_byte { |a_byte| r |= (a_byte ^ b_bytes.shift) }

    return(r == 0)
  end
end
