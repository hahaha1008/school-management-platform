#!/usr/bin/env bash
set -o errexit

# Force specific platform
export BUNDLE_FORCE_RUBY_PLATFORM=1

# Skip development and test gems
bundle config set --local without 'development test'

# Install dependencies with explicit platform
bundle install

# Asset compilation
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Database setup
bundle exec rake db:migrate
bundle exec rake db:seed