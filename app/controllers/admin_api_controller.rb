# frozen_string_literal: true

class AdminApiController < ApplicationController
  include AdminAuth

  before_action :authorize_admin!
  skip_before_action :verify_authenticity_token
end
