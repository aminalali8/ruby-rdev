FROM ruby:3.2.2-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile first to leverage Docker cache
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# Copy the rest of the application
COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "3000"] 