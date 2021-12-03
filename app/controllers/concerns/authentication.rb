# frozen_string_literal: true

module Authentication
  def check_login
    auth_header = request.headers["HTTP_AUTHORIZATION"]

    if auth_header&.start_with?("Bearer ")
      token = auth_header[7..-1]
      return true if authenticate_api_token(token)
    end

    render status: 403, json: { error: {code: "unauthorized"} }
  end

  private

  def authenticate_api_token(token)
    begin
      bin_token = Base64.urlsafe_decode64(token)
    rescue ArgumentError
      return false
    end

    api_key = ApiKey
      .eager_load(:workspace)
      .where(deleted_at: nil)
      .where('expires_at IS NULL OR expires_at > ?', Time.now)
      .find_by(secret: bin_token)

    return false unless api_key.present?

    # time_now = Time.now.utc
    # TODO: improve performance
    # api_key.update_columns(last_used_at: time_now, updated_at: time_now)

    @workspace = api_key.workspace
  end
end
