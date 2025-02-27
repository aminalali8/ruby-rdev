# Start with Alpine Linux
FROM alpine:3.18

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    nodejs \
    npm \
    yaml-dev \
    zlib-dev \
    openssl-dev \
    readline-dev \
    linux-headers \
    sqlite-dev \
    git \
    bash \
    tzdata

# Build and install Ruby
ENV RUBY_VERSION=3.2.2
ENV RUBY_DOWNLOAD_SHA256=96c57558871a6748de5bc9f274e93f4b5aad06cd8f37befa0e8d94e7b8a423bc

RUN wget -O ruby.tar.gz "https://cache.ruby-lang.org/pub/ruby/${RUBY_VERSION%.*}/ruby-$RUBY_VERSION.tar.gz" && \
    echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - && \
    mkdir -p /usr/src/ruby && \
    tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 && \
    rm ruby.tar.gz && \
    cd /usr/src/ruby && \
    ./configure --disable-install-doc && \
    make -j "$(nproc)" && \
    make install && \
    rm -rf /usr/src/ruby

# Install bundler
RUN gem install bundler

# Set working directory
WORKDIR /app

# Install Rails dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs "$(nproc)" --retry 5

# Copy the main application
COPY . .

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Configure the main process to run when running the image
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"] 