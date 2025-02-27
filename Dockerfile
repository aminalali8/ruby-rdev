FROM ruby:3.2.2-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile first to leverage Docker cache
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 3000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"] 