# syntax=docker/dockerfile:1
############################################
# Builder stage: installs deps, builds gems, bun and compiles assets
############################################
ARG RUBY_VERSION=3.4.7
FROM ruby:${RUBY_VERSION}-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    BUNDLE_JOBS=4 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    RAILS_ENV=production \
    BUN_VERSION=1.2.3 \
    BUN_INSTALL=/usr/local/bun \
    PATH=/usr/local/bun/bin:$PATH

# System deps for building gems and runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      ca-certificates \
      git \
      libpq-dev \
      pkg-config \
      unzip \
      gnupg \
      libc6-dev && \
    rm -rf /var/lib/apt/lists/*

# Install bun (node) - pinned version
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"

WORKDIR /rails

# Copy only what is needed for bundle install and bun install to use Docker cache
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v "$(awk '/^gem \"bundler\"/ {print $0}' Gemfile 2>/dev/null || true)" || true
RUN bundle config set deployment 'true' && bundle config set without 'development:test' && bundle install --jobs 4 --retry 3

# Copy JS manifest files and install node deps (bun)
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile

# Copy the rest of the app
COPY . .

# Precompile bootsnap and Rails assets (propshaft + bun)
RUN bundle exec bootsnap precompile --gemfile || true

# Provide a dummy DATABASE_URL to allow asset compilation during image build
ENV SECRET_KEY_BASE=dummy SECRET_KEY_BASE_DUMMY=1
RUN DATABASE_URL=postgresql://user:pass@localhost/dummy RAILS_ENV=production \
    ./bin/rails assets:precompile

# Remove build-only caches that won't be needed in final image
############################################
# Final runtime image
############################################
FROM ruby:${RUBY_VERSION}-slim AS final

ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_PATH=/usr/local/bundle \
    PATH=/usr/local/bun/bin:$PATH

# Install runtime deps only
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      ca-certificates \
      libpq5 \
      postgresql-client \
      libjemalloc2 \
      gnupg \
      unzip && \
    rm -rf /var/lib/apt/lists/*


# Install bun runtime (reuse same bun install command)
ARG BUN_VERSION=1.2.3
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"

# Create app user and runtime directories
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    mkdir -p /rails /rails/tmp /rails/log /rails/storage && \
    chown -R rails:rails /rails

WORKDIR /rails

# Copy gems and app from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /usr/local/bun /usr/local/bun
COPY --from=builder /rails /rails

# Ensure ownership and permissions
RUN chown -R rails:rails /rails && chmod -R u+rwX /rails

# Switch to non-root
USER rails

# Provide entrypoint (will be copied below)
COPY --chown=rails:rails bin/docker-entrypoint /rails/bin/docker-entrypoint
RUN chmod +x /rails/bin/docker-entrypoint

# Expose port 80 for Kamal proxy
EXPOSE 80

# Healthcheck: hits /up endpoint expected to return 200
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost/up || exit 1

# Entrypoint prepares DB and then execs the CMD
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Default command: run Puma on port 80 (bind 0.0.0.0)
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:80", "-C", "config/puma.rb"]