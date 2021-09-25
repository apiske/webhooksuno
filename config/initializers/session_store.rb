
Rails.application.config.session_store :redis_session_store, {
  key: 'napisession',
  redis: {
    expire_after: 24.hours,  # cookie expiration
    # ttl: 120.minutes,           # Redis expiration, defaults to 'expire_after'
    key_prefix: Comff.get_str('app.session_store.prefix'),
    url: Comff.get_str('app.session_store.url')
  }
}
