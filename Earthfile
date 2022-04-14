ARG RUBY_VERSION=2.7.6
FROM ruby:$RUBY_VERSION-slim-bullseye

WORKDIR /uno
ENV BUNDLE_APP_CONFIG=/uno/bundle

rb:
  RUN gem update --system
  RUN groupadd -r -g 1001 uno && \
      useradd -r -g uno -u 1001 uno

build:
  FROM +rb
  COPY Gemfile Gemfile
  COPY Gemfile.lock Gemfile.lock
  COPY vendor vendor

  RUN apt-get update -y ; \
      apt-get install -y libpq-dev libsodium-dev build-essential ; \
      rm -rf /var/lib/apt/lists/*

  RUN bundle config set --local path /uno/bundle/vendor ; \
      bundle config set --local without 'development test' ; \
      bundle config set --local deployment 'true'

  RUN bundle install -j8

  SAVE ARTIFACT /uno/bundle /bundle

docker:
  FROM +rb

  RUN apt-get update -y && \
      apt-get install -y libpq5 libsodium23 && \
      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
      rm -rf /var/lib/apt/lists/*

  RUN chown -R uno:uno /uno
  USER 1001

  COPY Gemfile Gemfile
  COPY Gemfile.lock Gemfile.lock

  COPY +build/bundle bundle

  COPY bin bin
  COPY db db
  COPY config config
  COPY app app
  COPY lib lib
  COPY vendor vendor
  COPY config.ru config.ru
  COPY Rakefile Rakefile
  COPY README.md README.md
  COPY script/entrypoint.sh entrypoint.sh

  RUN mkdir -p tmp/pids ; \
      mkdir log

  ENV RAILS_ENV=production
  ENV PUMA_THREADS=8:32
  ENV PORT=8080

  EXPOSE $PORT

  ENTRYPOINT ["/uno/entrypoint.sh"]

  ARG TAG
  SAVE IMAGE webhooksuno/webhooksuno:$TAG
