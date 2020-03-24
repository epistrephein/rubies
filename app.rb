# frozen_string_literal: true

require 'sinatra/base'

require 'json'
require 'redis'

REDIS = Redis.new(url: ENV['REDIS_URL'])

class Rubies < Sinatra::Base
  # Configuration
  configure :production, :development do
    enable :logging
  end

  configure :production do
    set :raise_errors,    false
    set :show_exceptions, false
    set :session_secret,  ENV.fetch('SESSION_SECRET', SecureRandom.hex(64))
    set :protection,      except: [:json_csrf]
  end

  # Settings
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
    headers 'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Methods' => %w[OPTIONS GET]
  end

  get %r{/api/(.*)} do |key|
    halt 404 unless REDIS.exists(key.to_s)
    REDIS.get(key.to_s)
  end

  # Errors
  not_found do
    status 404
    if request.path_info =~ %r{^/api/}
      { error: 'Not Found', status: 404 }.to_json
    else
      @title = 'Rubies - 404'
      erb :error
    end
  end
end
