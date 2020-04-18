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
    @branches_ex = REDIS.lrange('__branches_ex', 0, -1).sample(4)
    @releases_ex = REDIS.lrange('__releases_ex', 0, -1).sample(6)

    @last_update = REDIS.get('__last_update')

    erb :index
  end

  before '/api/*' do
    content_type 'application/json; charset=utf-8'

    headers 'Access-Control-Allow-Methods' => 'HEAD, GET, OPTIONS',
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Headers' => 'accept, authorization, origin'
  end

  get '/api/:key' do |key|
    halt 404 if key.start_with?('__') || !REDIS.exists(key.to_s)
    REDIS.get(key.to_s)
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
