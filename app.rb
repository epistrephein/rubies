# frozen_string_literal: true

require 'sinatra/base'

require 'json'
require 'redis'

REDIS = Redis.new(url: ENV['REDIS_URL'])

class Rubies < Sinatra::Base
  # Configuration
  configure :production, :development do
    enable :logging
    enable :sessions
  end

  configure :production do
    set :raise_errors,    false
    set :show_exceptions, false
    set :session_secret,  ENV.fetch('SESSION_SECRET', SecureRandom.hex(64))
  end

  # Settings
  set :server,        :thin
  set :app_file,      __FILE__
  set :root,          File.dirname(settings.app_file)
  set :public_folder, File.join(settings.root, 'public')

  # Filters
  before do
    @title = 'Rubies'
  end

  # Routes
  get '/' do
    @normal      = JSON.parse(REDIS.get('normal'))
    @security    = JSON.parse(REDIS.get('security'))
    @last_update = JSON.parse(REDIS.get('last_update'))['last_update']
    @version     = JSON.parse(REDIS.get('version'))['version']
    erb :index
  end

  # API
  before '/api/*' do
    content_type 'application/json; charset=utf-8'
  end

  get %r{/api/(.*)} do |key|
    unless REDIS.exists(key.to_s)
      halt 404, { error: 'Not Found', status: 404 }.to_json
    end
    REDIS.get(key.to_s)
  end

  # Errors
  not_found do
    status 404
    @title = 'Rubies - 404'
    erb :error unless request.path_info =~ %r{^/api/}
  end
end
