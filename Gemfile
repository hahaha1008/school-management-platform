source "https://rubygems.org"

gem "rails", "~> 8.0.1"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

# Gemfile
gem 'devise'
gem 'devise-jwt'  # For JWT token authentication in API
gem 'rack-cors'
gem 'action_policy'
gem 'jwt'

group :development do
  gem "web-console"
  gem 'letter_opener'
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem 'image_processing', '~> 1.2'

gem 'active_storage_validations'