# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra/base'
require 'redis'
require 'json'

REDIS ||= Redis.new(url: ENV['REDIS_URL'])

class Rubies < Sinatra::Base
  configure do
    set :logging,    true
    set :protection, except: [:json_csrf]
  end

  configure :production do
    set :raise_errors,    false
    set :show_exceptions, false

    set :static_cache_control, [:public, :must_revalidate, max_age: 30672000]
  end

  set :app_file,      __FILE__
  set :root,          File.dirname(settings.app_file)
  set :public_folder, File.join(settings.root, 'public')

  before do
    @version = REDIS.get('__version')
  end

  get '/' do
    @normal      = REDIS.lrange('__normal',   0, -1)
    @security    = REDIS.lrange('__security', 0, -1)

    @statuses_ex = REDIS.lrange('__statuses_ex', 0, -1)
    @branches_ex = REDIS.lrange('__branches_ex', 0, -1)
    @releases_ex = REDIS.lrange('__releases_ex', 0, -1)

    @last_update = REDIS.get('__last_update')

    REDIS.incr('__metric:home')
    erb :index
  end

  get '/ping' do
    halt :ok
  end

  before '/api/*' do
    content_type 'application/json; charset=utf-8'

    headers 'Access-Control-Allow-Methods' => 'HEAD, GET, OPTIONS',
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Headers' => 'accept, authorization, origin'
  end

  get '/api/:key' do |key|
    halt 404 if key.start_with?('__') || !REDIS.exists(key)

    REDIS.incr("__metric:#{key}")
    REDIS.get(key)
  end

  not_found do
    halt if request.path_info =~ %r{^/api/}

    @title = 'Rubies | 404'
    erb :not_found
  end

  error do
    halt if request.path_info =~ %r{^/api/}

    @title = 'Rubies | Error'
    erb :error
  end
end
