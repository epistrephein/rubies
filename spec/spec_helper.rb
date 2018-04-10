# frozen_string_literal: true

require 'bundler/setup'
require 'rack/test'

require_relative '../app.rb'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Make Rack::Test available to all spec contexts
  config.include Rack::Test::Methods

  # Load Sinatra app for Rack testing
  def app
    Rubies
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
