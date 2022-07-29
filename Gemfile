# frozen_string_literal: true

source 'https://rubygems.org'

gem 'octokit', '~> 5.1'
gem 'rack-cors', '~> 1.1'
gem 'rake', '~> 13.0'
gem 'redis', '~> 4.0'
gem 'sinatra', '~> 2.0'

group :production do
  gem 'unicorn', '~> 6.0'
  gem 'whenever', '~> 1.0', require: false
end

group :development, :test do
  gem 'rubocop', '~> 1.19'
  gem 'thin', '~> 1.7'
end

group :test do
  gem 'mock_redis', '~> 0.19'
  gem 'rack-test', '~> 1.1'
  gem 'rspec', '~> 3.6'
  gem 'simplecov', '~> 0.21.2'
  gem 'webmock', '~> 3.8'
end

group :development do
  gem 'foreman'
  gem 'pry', '~> 0.12'
  gem 'rerun', '~> 0.13'
end
