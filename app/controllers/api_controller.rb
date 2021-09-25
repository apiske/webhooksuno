# frozen_string_literal: true

class ApiController < ApplicationController
  MSGPACK_MIME = "application/vnd.msgpack"
  JSON_MIME = "application/json"

  InvalidContentTypeError = Class.new(StandardError)

  include Authentication
  include CerealRendering

  skip_before_action :verify_authenticity_token
  before_action :check_login
  rescue_from UuidUtil::InvalidUuidError, with: :fail_invalid_uuid!
  rescue_from ActiveRecord::RecordNotFound, with: :fail_not_found!
  # rescue_from Spyderweb::Kellogs::Cereal::CerealizationClientError # TODO!

  protected

  def fail_not_found!
    render json: {
        error: {
          code: "not_found",
        }
      }, status: 404
  end

  def fail_invalid_uuid!
    render json: {
        error: {
          code: "invalid_uuid"
        }
      }, status: 400
  end

  def body_obj
    @body_obj ||= begin
      type = request.env["CONTENT_TYPE"]
      case type
      when MSGPACK_MIME
        MessagePack.unpack(request.body.read)
      when JSON_MIME
        MultiJson.load(request.body.read)
      else
        raise InvalidContentTypeError.new("'#{type}' is invalid")
      end
    end
  end

  def fail_validation!(errors)
    failed_validations = []
    errors.messages.each do |msg|
      failed_validations << {
        path: msg.path.to_a.join("/"),
        message: msg.text
      }
    end

    payload = {
      error: "validation_error",
      failed_validations: failed_validations
    }

    render status: 400, body: MultiJson.dump(payload), content_type: 'application/json'
  end
end
