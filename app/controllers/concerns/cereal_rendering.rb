module CerealRendering
  DEFAULT_SERIALIZERS = [
    TopicSerializer,
    TagSerializer,
    RouterSerializer,
    WebhookDefinitionSerializer,
    KeySerializer,
    BindingRequestSerializer,
    SubscriptionSerializer
  ].freeze

  def make_cereal
    Spyderweb::Kellogs::Renderer.new(request,
      serializers: DEFAULT_SERIALIZERS,
      params: params
    ).cereal
  end

  def render_single(obj)
    c = make_cereal
    mime, body = c.render_model(obj)
    render status: 200, body: body, content_type: mime
  end

  def render_collection(col)
    c = make_cereal
    mime, body = c.render_collection(col)
    render status: 200, body: body, content_type: mime
  end
end
