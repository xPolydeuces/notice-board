# syntax=docker/dockerfile:1

############################################
# Builder stage
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

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      ca-certificates \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config \
      unzip \
      gnupg \
      libc6-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Bun (stable, safe)
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"

WORKDIR /rails

# Copy bundle files
COPY Gemfile Gemfile.lock ./

# Install bundler (Rails 8 needs modern bundler)
RUN gem install bundler -v "~> 2.5"

RUN bundle config set deployment true && \
    bundle config set without 'development:test' && \
    bundle install --jobs 4 --retry 3

# Copy JS package manifests
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile

# Copy full app
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile --gemfile || true

# Dummy env needed for asset compilation
ENV SECRET_KEY_BASE=dummy

RUN DATABASE_URL=postgres://user:pass@localhost/dummy \
    RAILS_ENV=production \
    ./bin/rails assets:precompile

############################################
# Final runtime stage
############################################
FROM ruby:${RUBY_VERSION}-slim AS final

ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_PATH=/usr/local/bundle \
    PATH=/usr/local/bun/bin:$PATH

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      ca-certificates \
      libpq5 \
      libjemalloc2 \
      postgresql-client \
      unzip \
      gnupg && \
    rm -rf /var/lib/apt/lists/*

# Install Bun runtime
ARG BUN_VERSION=1.2.3
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"

# Create rails user
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    mkdir -p /rails && \
    chown -R rails:rails /rails

WORKDIR /rails

# Copy artifacts from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /usr/local/bun /usr/local/bun
COPY --from=builder /rails /rails

RUN chown -R rails:rails /rails

USER rails

# Copy entrypoint
COPY --chown=rails:rails bin/docker-entrypoint /rails/bin/docker-entrypoint
RUN chmod +x /rails/bin/docker-entrypoint

# Puma runs on port 3000 internally
ENV PORT=3000
EXPOSE 3000

# Healthcheck for Kamal - use shell form to expand $PORT, with start period for db:prepare
HEALTHCHECK --start-period=60s --interval=10s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
