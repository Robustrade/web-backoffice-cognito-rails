#!/bin/sh

set -e

# Set RAILS_ENV if ENV_VALUE is provided
if [ -n "$ENV_VALUE" ]; then
  export RAILS_ENV="$ENV_VALUE"
else
  export RAILS_ENV="development"
fi

# Function to start Rails server
start_rails() {
  echo "Starting Rails server..."
  exec rails server -b 0.0.0.0
}

# Function to start Sidekiq
start_sidekiq() {
  echo "Starting Sidekiq..."
  exec bundle exec sidekiq
}

# Determine which process to run based on the first argument
case "$1" in
  sidekiq)
    start_sidekiq
    ;;
  *)
    start_rails
    ;;
esac