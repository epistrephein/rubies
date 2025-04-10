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
    set :host_authorization, { permitted_hosts: [] }
  end

  configure :production do
    set :raise_errors,    false
    set :show_exceptions, false

    set :static_cache_control, [:public, :must_revalidate, { max_age: 30672000 }]
  end

  set :app_file,      __FILE__
  set :root,          File.dirname(settings.app_file)
  set :public_folder, File.join(settings.root, 'public')

  get '/' do
    @normal      = REDIS.lrange('rubies:web:normal',   0, -1)
    @security    = REDIS.lrange('rubies:web:security', 0, -1)

    @statuses_ex = REDIS.lrange('rubies:web:statuses_ex', 0, -1)
    @branches_ex = REDIS.lrange('rubies:web:branches_ex', 0, -1)
    @releases_ex = REDIS.lrange('rubies:web:releases_ex', 0, -1)

    @last_update = REDIS.get('rubies:web:last_update')

    erb :index
  end

  get '/ping' do
    halt :ok
  end

  before '/api/*' do
    content_type :json

    headers 'Access-Control-Allow-Methods' => 'HEAD, GET',
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Headers' => 'accept, authorization, origin'
  end

  get '/api/:key' do |key|
    halt 404 unless REDIS.exists?("rubies:api:#{key}")

    REDIS.get("rubies:api:#{key}")
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
