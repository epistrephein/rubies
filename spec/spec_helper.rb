# frozen_string_literal: true

require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'mock_redis'
require 'rack/test'
require 'webmock/rspec'

# Set RACK_ENV to production to test error handling in production mode
ENV['RACK_ENV'] = 'production'

MOCKREDIS = MockRedis.new

require_relative '../lib/remote'
require_relative '../lib/branch'
require_relative '../lib/release'
require_relative '../app'

RSpec.configure do |config|
  # Make Rack::Test available to all spec contexts
  config.include Rack::Test::Methods

  # Attach WebMock and disable connections
  WebMock.disable_net_connect!(allow_localhost: true)

  # Turn on all Ruby warnings
  config.warnings = :all

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Enable temporarily focused examples and groups
  config.filter_run_when_matching :focus

  # Use the documentation formatter for detailed output
  config.default_formatter = 'doc'

  # Run specs in random order to surface order dependencies
  config.order = :random

  # Seed Ruby's global RNG with RSpec's seed for reproducibility
  Kernel.srand config.seed

  # Load Sinatra app for Rack testing
  def app
    Rubies
  end

  # Load requests fixtures for WebMock
  def fixture(name)
    file = File.join(__dir__, 'fixtures', "#{name}.json")
    File.read(file)
  end

  # Populate MockRedis
  redis_fixture = JSON.parse(fixture('redis'))
  redis_fixture.each { |k, v| MOCKREDIS.set("rubies:api:#{k}", v.to_json) }

  # Stub Redis as MockRedis
  config.before(:each, :redis) do
    stub_const('REDIS', MOCKREDIS)
  end

  # Stub GitHub API responses
  config.before(:each, :github) do
    stub_request(:get, %r{_data/branches.yml})
      .to_return(
        status:  200,
        body:    fixture('branches'),
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  config.before(:each, :github) do
    stub_request(:get, %r{_data/releases.yml})
      .to_return(
        status:  200,
        body:    fixture('releases'),
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
