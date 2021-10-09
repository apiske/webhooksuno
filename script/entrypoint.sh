#!/bin/bash

set -eux

export RAILS_LOG_TO_STDOUT=1

if [ "$1" == "api" ]; then
  puma_bind=tcp://0.0.0.0:$PORT

  if [ "${TLS_ENABLED:-}" == "true" ]; then
    puma_bind="ssl://0.0.0.0:${PORT}?key=${TLS_KEY_PATH}&cert=${TLS_CERT_PATH}"
  fi

  bundle exec puma -b $puma_bind -e $RAILS_ENV -t "$PUMA_THREADS" -v
elif [ "$1" == "worker" ]; then
  bundle exec rjob --run-workers --use-rails
elif [ "$1" == "console" ]; then
  bin/rails console
elif [ "$1" == "migrate" ]; then
  bin/rails db:migrate
elif [ "$1" == "create-sender" ]; then
  bin/rails uno:createsender
elif [ "$1" == "create-receiver" ]; then
  bin/rails uno:createreceiver
else
  echo "Invalid command '$1'. Must be one of: api, worker, console, migrate, create-sender or create-receiver"
fi
