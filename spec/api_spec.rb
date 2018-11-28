# frozen_string_literal: true

require 'json'
require 'time'

RSpec.describe 'Rubies API' do
  it 'returns the API versions' do
    get '/api/version'
    json = JSON.parse(last_response.body)

    expect(json.fetch('version')).to be > '0'
  end

  it 'returns each status key' do
    %w[active normal security preview eol].each do |key|
      get "/api/#{key}"
      json = JSON.parse(last_response.body)

      expect(last_response.status).to be 200
      expect(json).to be_a(Array)
    end
  end

  it 'returns the last update' do
    get '/api/last_update'
    json = JSON.parse(last_response.body)

    expect(Time.parse(json.fetch('last_update'))).to be_a(Time)
  end

  it 'is updated in the last hour' do
    get '/api/last_update'
    json = JSON.parse(last_response.body)

    expect(Time.parse(json.fetch('last_update')))
      .to be_within(3600).of Time.now
  end
end
