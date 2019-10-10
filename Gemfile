# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.3.1'

gem 'nokogiri', '~> 1.8'
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
  gem 'guard'
  gem 'guard-rspec'
  gem 'rack-test'
  gem 'rspec'
end

group :development do
  gem 'bundler'
  gem 'foreman'
  gem 'pry'
  gem 'rerun'
  gem 'rubocop'
end
