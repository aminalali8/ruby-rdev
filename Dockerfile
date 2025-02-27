FROM ruby:3.2.2-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user with matching group ID
RUN groupadd -r -g 1000 appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# Copy Gemfile first to leverage Docker cache
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set ownership to appuser:appuser explicitly
RUN chown -R appuser:appuser /app && \
    chmod -R 755 /app

EXPOSE 3000

# Run supervisord as root (needed for the permissions watcher)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 