# frozen_string_literal: true

require 'rack/cors'
require_relative 'app'

use Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', headers: :any, methods: [:head, :get, :options]
  end
end

run Rubies
