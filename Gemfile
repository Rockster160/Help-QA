source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Defaults
gem 'rails', '~> 5.0.2'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'

gem 'jquery-rails'
gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 3.0'
# /Defaults

# Essentials
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'autoprefixer-rails'
gem 'font-awesome-rails'
gem 'colorize'
gem 'faker'
gem 'rspec'
gem 'factory_girl_rails'
# / Essentials

gem 'devise'
gem 'rest-client'
gem 'has_friendship'
gem 'chroma'
gem 'oily_png'
gem 'kaminari'

group :development, :test do
  gem 'byebug', platform: :mri

  gem 'annotate'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'better_errors'
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
