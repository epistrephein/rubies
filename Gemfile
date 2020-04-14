# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.3.1'

gem 'octokit', '~> 4.18'
gem 'rack-cors', '~> 1.1'
gem 'rake', '~> 13.0'
gem 'redis', '~> 4.0'
gem 'sinatra', '~> 2.0'

group :production do
  gem 'unicorn', '~> 5.4'
  gem 'whenever', '~> 1.0', require: false
end

group :test, :development do
  gem 'thin'
end

group :test do
  gem 'mock_redis'
  gem 'rack-test'
  gem 'rspec'
  gem 'webmock'
end

group :development do
  gem 'foreman'
  gem 'pry'
  gem 'rerun'
  gem 'rubocop', '~> 0.80.0'
end
