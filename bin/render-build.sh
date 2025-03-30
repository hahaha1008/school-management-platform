#!/usr/bin/env bash
set -o errexit

# Force platform to ensure compatibility
bundle config set --local force_ruby_platform true
bundle config set --local without development test
bundle install

# Asset compilation
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Database setup
bundle exec rake db:migrate
bundle exec rake db:seed