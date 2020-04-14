# frozen_string_literal: true

require 'json'
require 'time'

RSpec.describe 'Rubies API', :redis do
  it 'returns the API versions' do
    get '/api/version'
    json = JSON.parse(last_response.body)

    expect(json.fetch('version')).to eq('2.0.0')
  end

  it 'returns each status key' do
    %w[normal security preview eol].each do |key|
      get "/api/#{key}"
      json = JSON.parse(last_response.body)

      expect(last_response.status).to be 200
      expect(json).to be_a(Hash)
      expect(json).to include('status', 'branches', 'latest')
    end
  end

  it 'returns the last update' do
    get '/api/last_update'
    json = JSON.parse(last_response.body)

    expect(Time.parse(json.fetch('last_update'))).to be_a(Time)
  end

  it 'responds to all endpoints' do
    endpoints = JSON.parse(fixture('redis')).keys

    endpoints.each do |endpoint|
      get "/api/#{endpoint}"
      json = JSON.parse(last_response.body)

      expect(last_response.status).to be 200
      expect(json).to be_a(Hash)
    end
  end

  it "returns 404 if the key doesn't exist" do
    get '/api/non-existent'

    expect(last_response.status).to be 404
  end
end
