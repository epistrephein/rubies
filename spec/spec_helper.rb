# frozen_string_literal: true

require 'bundler/setup'
require 'mock_redis'
require 'rack/test'
require 'webmock/rspec'

require_relative '../lib/remote'
require_relative '../lib/branch'
require_relative '../lib/release'
require_relative '../app'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  # Make Rack::Test available to all spec contexts
  config.include Rack::Test::Methods

  # Attach WebMock and disable connections
  WebMock.disable_net_connect!(allow_localhost: true)

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Enable temporarily focused examples and groups
  config.filter_run_when_matching :focus

  # Use the documentation formatter for detailed output
  config.default_formatter = 'doc'

  # Run specs in random order to surface order dependencies
  config.order = :random

  # Use expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Load requests fixtures for WebMock
  def fixture(name)
    file = File.join(__dir__, 'fixtures', "#{name}.json")
    File.read(file)
  end

  config.before(:example) do
    mr = MockRedis.new
    stub_const('REDIS', mr)
    mr.set('version', {version: "7.0.1"}.to_json)
  end

  # Load Sinatra app for Rack testing
  def app
    Rubies
  end
end
