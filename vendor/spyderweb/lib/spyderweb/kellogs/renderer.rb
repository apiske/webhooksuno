# frozen_string_literal: true

class Spyderweb::Kellogs::Renderer
  attr_reader :request
  attr_reader :params
  attr_reader :serializers
  attr_reader :pagination_cursor_key

  def initialize(request, serializers:, params:, pagination_cursor_key:)
    @request = request
    @params = params
    @serializers = serializers
    @pagination_cursor_key = pagination_cursor_key
  end

  def cereal
    create_serializer_instances

    accept_type = @request.env['HTTP_ACCEPT']

    Spyderweb::Kellogs::Cereal.new(
      @serializer_instances,
      {
        mime_type: accept_type,
        fields_filter: @params[:fields],
        rel_fmt: @params[:rel_fmt],
        pagination_cursor_key: @pagination_cursor_key,
      }
    )
  end

  private

  def create_serializer_instances
    @serializer_instances = @serializers.map do |klass|
      klass.new
    end
  end
end
