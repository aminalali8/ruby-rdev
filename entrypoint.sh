#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Initialize Rails if it hasn't been initialized
if [ ! -f /app/config/application.rb ]; then
  echo "Initializing Rails application..."
  bash /app/init_rails.sh
fi

# Create and migrate database
bundle exec rails db:create db:migrate 2>/dev/null || true

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@" 