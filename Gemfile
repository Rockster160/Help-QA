source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '3.2.2'

# Defaults
gem 'rails', '~> 7.0.8'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.4'
gem 'sprockets-rails'
gem 'sassc-rails'
gem 'terser'
gem 'coffee-rails', '~> 5.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jbuilder', '~> 2.11'
gem 'redis', '~> 5.0'
# /Defaults

# Essentials
gem 'sidekiq', '~> 7.2'
gem 'sidekiq-cron', '~> 1.12'
# connection_pool 3.0 changed TimedStack#pop's signature; Sidekiq 7.3 still
# calls it with an argument, which kills the scheduler thread (no retries, no
# scheduled jobs, no cron). Sidekiq's own dependency is too loose to prevent it.
gem 'connection_pool', '~> 2.5'
gem 'autoprefixer-rails'
gem 'font-awesome-rails'
gem 'colorize'
gem 'faker'
gem 'factory_bot_rails'
# / Essentials

gem 'devise', '~> 4.9'
gem 'rest-client'
gem 'has_friendship'
gem 'chroma'
gem 'chunky_png'
gem 'kaminari'
gem 'slack-notifier'
gem 'browser-timezone-rails'
gem 'obscenity'
gem 'aws-sdk-s3'
gem 'kt-paperclip', '~> 7.2'
gem 'exception_notification'
gem 'stripe'
gem 'differ'
gem 'nokogiri', '~> 1.16'

group :development, :test do
  gem 'byebug', platform: :mri

  gem 'annotate'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rspec-rails', '~> 6.1'
end

group :development do
  gem 'web-console', '>= 4.2'
  gem 'listen', '~> 3.8'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
