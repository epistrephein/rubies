# frozen_string_literal: true

RSpec.describe Rubies, :redis do
  describe 'HTML' do
    it 'loads the home page' do
      get '/'

      expect(last_response).to be_ok
    end

    it 'returns a 404 page' do
      get '/non-existent'

      expect(last_response).to be_not_found
    end
  end

  describe 'JSON API' do
    context 'all endpoints' do
      endpoints = JSON.parse(fixture('redis')).keys

      endpoints.each do |endpoint|
        it "responds to #{endpoint}" do
          get "/api/#{endpoint}"
          json = JSON.parse(last_response.body)

          expect(json).to include('status', 'branches', 'latest')
                      .or include('branch', 'status', 'release_date', 'eol_date',
                                  'latest', 'releases')
                      .or include('release', 'branch', 'status', 'release_date',
                                  'latest', 'prerelease')
                      .or include('version')
                      .or include('last_update')
        end
      end
    end

    it 'returns the version' do
      get '/api/version'
      json = JSON.parse(last_response.body)

      expect(json.fetch('version')).to eq(VERSION_FULL)
    end

    it 'returns the last update time' do
      get '/api/last_update'
      json = JSON.parse(last_response.body)

      expect(Time.parse(json.fetch('last_update'))).to be_a(Time)
    end

    it "returns 404 if the key doesn't exist" do
      get '/api/non-existent'

      expect(last_response).to be_not_found
    end
  end
end
