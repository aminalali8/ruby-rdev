FROM ruby:3.2.2-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    supervisor \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile first to leverage Docker cache
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# Copy the watch script and make it executable
COPY watch_permissions.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/watch_permissions.sh

# Copy the rest of the application
COPY . .

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Ensure watch script stays executable
RUN chmod +x watch_permissions.sh

EXPOSE 3000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 