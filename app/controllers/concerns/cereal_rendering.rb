# frozen_string_literal: true

module CerealRendering
  DEFAULT_SERIALIZERS = [
    TopicSerializer,
    TagSerializer,
    RouterSerializer,
    WebhookDefinitionSerializer,
    KeySerializer,
    SubscriptionSerializer,
    ReceiverBindingSerializer
  ].freeze

  def make_cereal
    Spyderweb::Kellogs::Renderer.new(request,
      serializers: DEFAULT_SERIALIZERS,
      pagination_cursor_key: pagination_cursor_key,
      params: params
    ).cereal
  end

  def render_single(obj, status=200)
    c = make_cereal
    mime, body = c.render_model(obj)
    render status: status, body: body, content_type: mime
  end

  def render_collection_paginated(col)
    page_size = 50
    page_cursor = params[:page]

    c = make_cereal
    mime, body = c.render_collection_paginated(col, page_cursor, page_size)
    render status: 200, body: body, content_type: mime
  end

  def render_collection(col)
    c = make_cereal
    mime, body = c.render_collection(col)
    render status: 200, body: body, content_type: mime
  end

  private

  def pagination_cursor_key
    Base64.strict_decode64(Comff.get_str!("app.pagination.cursor_key"))    
  end
end
