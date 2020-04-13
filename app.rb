# frozen_string_literal: true

require 'sinatra/base'
require 'redis'
require 'json'

REDIS = Redis.new(url: ENV['REDIS_URL'])

class Rubies < Sinatra::Base
  configure :production, :development do
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

  get '/' do
    @normal      = JSON.parse(REDIS.get('normal'))['latest']
    @security    = JSON.parse(REDIS.get('security'))['latest']

    @last_update = JSON.parse(REDIS.get('last_update'))['last_update']
    @version     = JSON.parse(REDIS.get('version'))['version']

    erb :index
  end

  before '/api/*' do
    content_type 'application/json; charset=utf-8'

    headers 'Access-Control-Allow-Methods' => 'HEAD, GET, OPTIONS',
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Headers' => 'accept, authorization, origin'
  end

  get %r{/api/(.*)} do |key|
    halt 404 unless REDIS.exists(key.to_s)
    REDIS.get(key.to_s)
  end

  not_found do
    halt if request.path_info =~ %r{^/api/}

    @title = 'Rubies - 404'
    erb :not_found
  end

  error do
    halt if request.path_info =~ %r{^/api/}

    @title = 'Rubies - 500'
    erb :error
  end
end
