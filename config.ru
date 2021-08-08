# frozen_string_literal: true

require 'rack/cors'
require_relative 'app'

use Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', headers: :any, methods: [:head, :get, :options]
  end
end

class IPFilterMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env.delete('HTTP_X_FORWARDED_FOR')
    env.delete('REMOTE_USER')

    env['REMOTE_ADDR'] = '0.0.0.0'

    @app.call(env)
  end
end

use IPFilterMiddleware

run Rubies
