# frozen_string_literal: true

module CerealRendering
  DEFAULT_SERIALIZERS = [
    TopicSerializer,
    TagSerializer,
    RouterSerializer,
    WebhookDefinitionSerializer,
    KeySerializer,
    SubscriptionSerializer
  ].freeze

  def make_cereal
    Spyderweb::Kellogs::Renderer.new(request,
      serializers: DEFAULT_SERIALIZERS,
      params: params
    ).cereal
  end

  def render_single(obj, status=200)
    c = make_cereal
    mime, body = c.render_model(obj)
    render status: status, body: body, content_type: mime
  end

  def render_collection(col)
    c = make_cereal
    mime, body = c.render_collection(col)
    render status: 200, body: body, content_type: mime
  end
end
