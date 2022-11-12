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
    valid, key_id, secret = extract_token_components(token)

    return false unless valid

    api_key = ApiKey
      .eager_load(:workspace)
      .where(deleted_at: nil)
      .where('expires_at IS NULL OR expires_at > ?', Time.now)
      .find_by(key_id: key_id)

    return false unless api_key.present?

    return false unless valid_key_secret?(api_key, secret)

    # time_now = Time.now.utc
    # TODO: improve performance
    # api_key.update_columns(last_used_at: time_now, updated_at: time_now)

    @workspace = api_key.workspace
  end

  def extract_token_components(token)
    return false unless token.length >= 64 && token.length <= 200

    key_id = token[0...32]
    key_secret = begin
                   Base64.urlsafe_decode64(token[32..])
                 rescue ArgumentError
                   return false
                 end

    [true, key_id, key_secret]
  end

  def valid_key_secret?(api_key, provided_secret)
    d = OpenSSL::Digest::SHA512.new
    d << api_key.key_salt
    d << provided_secret
    digest = d.digest

    r = 0
    (0...64).each do |idx|
       r |= (api_key.key_secret.b[idx].ord ^ digest.b[idx].ord)
    end

    r == 0
  end
end
