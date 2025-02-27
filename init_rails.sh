#!/bin/bash

# Remove any existing application files except Docker-related files
find . -mindepth 1 -maxdepth 1 ! -name 'Dockerfile' ! -name 'docker-compose.yml' ! -name 'entrypoint.sh' ! -name '.git' ! -name '.gitignore' ! -name 'init_rails.sh' -exec rm -rf {} +

# Create new Rails application with PostgreSQL
rails new . --database=postgresql --skip-git --skip-bundle

# Copy our existing configuration files back
cp config/database.yml.bak config/database.yml 2>/dev/null || true

# Install all dependencies
bundle install 