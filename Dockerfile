FROM ruby:3.2.2-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# Copy Gemfile first to leverage Docker cache
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Set ownership to appuser
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 3000

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "3000"] 