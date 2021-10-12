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
      type = request.env.fetch("CONTENT_TYPE", JSON_MIME)
      case type
      when MSGPACK_MIME
        MessagePack.unpack(request.body.read)
      when JSON_MIME
        MultiJson.load(request.body.read)
      else
        raise InvalidContentTypeError.new("'#{type}' is not supported")
      end
    end
  end

  def fail_on_invalid_body_payload!
    begin
      body_obj
    rescue InvalidContentTypeError => e
      render status: :unsupported_media_type, body: MultiJson.dump({
        error: "invalid_content_type",
        message: "The Content-Type header must be either #{JSON_MIME} (default if header is not present) or #{MSGPACK_MIME}." +
                 " The provided #{e.message}"
      }), content_type: 'application/json'

      return true
    rescue MultiJson::ParseError
      render status: :bad_request, body: MultiJson.dump({
        error: "invalid_json_content",
        message: "The provided body is not a valid JSON content"
      }), content_type: 'application/json'

      return true
    rescue MessagePack::MalformedFormatError
      render status: :bad_request, body: MultiJson.dump({
        error: "invalid_message_pack",
        message: "The provided body is not a valid MessagePack content"
      }), content_type: 'application/json'

      return true
    end

    if !body_obj.is_a?(Hash) || !body_obj.key?("data") || body_obj.keys.length != 1
      render status: :unprocessable_entity, body: MultiJson.dump({
        error: "validation_error",
        message: "The immediate payload must be a JSON object with one attribute named 'data'." +
                 " No other immediate attributes are allowed to be present." +
                 " All entity attributes must be located within the 'data' attribute"
      }), content_type: 'application/json'

      return true
    end

    false
  end

  def fail_on_invalid_processor!(processor)
    return false if processor.valid?

    failed_validations = processor.errors.map do |attr, err_msg|
      {
        path: "data." + (attr.is_a?(Apidef::Attribute) ? attr.name : attr.to_s),
        message: err_msg
      }
    end

    payload = [
      error: "validation_error",
      failed_validations: failed_validations
    ]

    render status: :unprocessable_entity, body: MultiJson.dump(payload), content_type: 'application/json'

    true
  end

  def fail_validation!(errors)
    failed_validations = []
    errors.messages.each do |msg|
      failed_validations << {
        path: msg.path.to_a.join("."),
        message: msg.text
      }
    end

    payload = {
      error: "validation_error",
      failed_validations: failed_validations
    }

    render status: :unprocessable_entity, body: MultiJson.dump(payload), content_type: 'application/json'
  end
end
