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

  configure :development do
    set :logging, Logger::DEBUG
  end

  set :app_file,      __FILE__
  set :root,          File.dirname(settings.app_file)
  set :public_folder, File.join(settings.root, 'public')

  # options '*' do
  #   response.headers['Allow'] = 'HEAD, GET, OPTIONS'
  #   response.headers['Access-Control-Allow-Headers'] = %w[
  #     X-Requested-With
  #     X-HTTP-Method-Override
  #     Content-Type
  #     Cache-Control
  #     Accept
  #   ].join(', ')

  #   status 200
  # end

  get '/' do
    # @normal      = JSON.parse(REDIS.get('normal'))
    # @security    = JSON.parse(REDIS.get('security'))
    @last_update = JSON.parse(REDIS.get('last_update'))['last_update']
    @version     = JSON.parse(REDIS.get('version'))['version']

    @normal      = []
    @security    = []
    erb :index
  end

  get '/error' do
    raise StandardError
  end

  before '/api/*' do
    content_type 'application/json; charset=utf-8'

    headers 'Access-Control-Allow-Methods' => 'HEAD, GET, OPTIONS',
            'Access-Control-Allow-Origin'  => '*',
            'Access-Control-Allow-Headers' => 'accept, authorization, origin'
  end

  get '/api/error' do
    raise StandardError
  end

  get %r{/api/(.*)} do |key|
  # get %r{/api(?:/(v\d+))?/(.*)} do |version, key|
  # get '/api/?:version?/?:key?' do
    # logger.debug('/api/') { "version: #{version}, key: #{key}" }
    # logger.debug('/api/') { "version: #{params[:version]}, key: #{params[:key]}" }
    # halt 404 unless REDIS.exists("#{version || 2}__#{key}")
    # REDIS.get("v#{version}__#{key}")
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
