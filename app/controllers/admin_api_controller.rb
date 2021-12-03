# frozen_string_literal: true

class AdminApiController < ApplicationController
  include AdminAuth

  before_action :authorize_admin!
  skip_before_action :verify_authenticity_token

  protected

  def body_obj
    @body_obj ||= MultiJson.load(request.body.read)
  end
end
