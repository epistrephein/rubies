# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.3.1'

gem 'nokogiri', '~> 1.8'
gem 'rake', '~> 12.3'
gem 'redis', '~> 4.0'
gem 'sinatra', '~> 2.0'
gem 'thin', '~> 1.7'

group :production do
  gem 'unicorn', '~> 5.4'
  gem 'whenever', '~> 0.10'
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
