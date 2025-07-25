# syntax=docker/dockerfile:1
# check=error=true


# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t store .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name store store


# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html


# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base


# Rails app lives here
WORKDIR /rails


# Install base packages
RUN apt-get update -qq && \
<<<<<<< HEAD
   apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
   rm -rf /var/lib/apt/lists /var/cache/apt/archives/*

=======
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives/*
>>>>>>> bdd6f04 (Update)

# Set production environment
ENV RAILS_ENV="production" \
   BUNDLE_DEPLOYMENT="1" \
   BUNDLE_PATH="/usr/local/bundle" \
   BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base AS build


# Install packages needed to build gems
RUN apt-get update -qq && \
<<<<<<< HEAD
   apt-get install --no-install-recommends -y curl gnupg && \
   curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
   apt-get install --no-install-recommends -y \
     nodejs \
     yarn \
     build-essential \
     git \
     libpq-dev \
     libyaml-dev \
     pkg-config \
     libssl-dev \
     libreadline-dev \
     zlib1g-dev && \
   rm -rf /var/lib/apt/lists/*


=======
    apt-get install --no-install-recommends -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install --no-install-recommends -y \
      nodejs \
      yarn \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config \
      libssl-dev \
      libreadline-dev \
      zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*
>>>>>>> bdd6f04 (Update)


# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
   rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
   bundle exec bootsnap precompile --gemfile


# Copy application code
COPY . .


# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

<<<<<<< HEAD

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY


RUN RAILS_MASTER_KEY=$(cat config/master.key) SECRET_KEY_BASE=foo ./bin/rails assets:precompile

=======
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
>>>>>>> bdd6f04 (Update)

RUN RAILS_MASTER_KEY=$(cat config/master.key) SECRET_KEY_BASE=foo ./bin/rails assets:precompile


# Final stage for app image
FROM base


# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails


# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
   useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
   chown -R rails:rails db log storage tmp
USER 1000:1000


# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]


# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]



