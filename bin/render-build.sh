#!/usr/bin/env bash
set -o errexit

# Use the simplified Gemfile for Render
if [ -f Gemfile.render ]; then
  mv Gemfile.render Gemfile
fi

# Clean any existing lock file
if [ -f Gemfile.lock ]; then
  rm Gemfile.lock
fi

# Install dependencies
bundle install --without development test

# Asset compilation
bundle exec rake assets:precompile
bundle exec rake assets:clean

# Database setup
bundle exec rake db:migrate
bundle exec rake db:seed