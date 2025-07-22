#!/usr/bin/env bash

set -o errexit

bundle install
yarn install --check-files


# Precompile assets AFTER environment is loaded
bundle exec rails assets:precompile

# Run DB migrations
bundle exec rails db:migrate