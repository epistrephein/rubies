# frozen_string_literal: true

RSpec.describe Rubies, :redis do
  context 'HTML' do
    let(:html) { last_response.body }

    describe 'homepage' do
      let(:endpoint) { '/' }

      it 'returns the home page' do
        get endpoint

        expect(last_response).to be_ok
        expect(html).to include('API interface to Ruby versions, releases and branches')
      end
    end

    describe 'not found' do
      let(:endpoint) { '/non-existent' }

      it 'returns a 404 page' do
        get endpoint

        expect(last_response).to be_not_found
        expect(html).to include("The page you're looking for doesn't exist")
      end
    end

    describe 'server error' do
      let(:endpoint) { '/error' }

      before { app.before('/error') { raise StandardError } }

      it 'returns a 500 page' do
        get endpoint

        expect(last_response).to be_server_error
      end
    end
  end

  context 'JSON API' do
    let(:json) { JSON.parse(last_response.body) }

    it 'responds to all endpoints' do
      all_endpoints = JSON.parse(fixture('redis')).keys
      all_endpoints.each do |endpoint|
        get "/api/#{endpoint}"

        expect(json)
          .to include('status', 'branches', 'latest')
          .or include('branch', 'status', 'release_date', 'eol_date', 'latest', 'releases')
          .or include('release', 'branch', 'status', 'release_date', 'latest', 'prerelease')
          .or include('version')
          .or include('last_update')
      end
    end

    describe 'status endpoint' do
      let(:endpoint) { '/api/normal' }

      it 'returns the status info' do
        get endpoint

        expect(json).to eq({
          'status'   => 'normal',
          'branches' => ['2.7', '2.6'],
          'latest'   => ['2.7.1', '2.6.6']
        })
      end
    end

    describe 'branch endpoint' do
      let(:endpoint) { '/api/2.7' }

      it 'returns the branch info' do
        get endpoint

        expect(json).to eq({
          'branch'       => '2.7',
          'status'       => 'normal',
          'release_date' => '2019-12-25',
          'eol_date'     => nil,
          'latest'       => '2.7.1',
          'releases'     => [
            '2.7.1', '2.7.0', '2.7.0-rc2', '2.7.0-rc1',
            '2.7.0-preview3', '2.7.0-preview2', '2.7.0-preview1'
          ]
        })
      end
    end

    describe 'release endpoint' do
      let(:endpoint) { '/api/2.7.0' }

      it 'returns the release info' do
        get endpoint

        expect(json).to eq({
          'release'      => '2.7.0',
          'branch'       => '2.7',
          'status'       => 'normal',
          'release_date' => '2019-12-25',
          'latest'       => false,
          'prerelease'   => false
        })
      end
    end

    describe 'version endpoint' do
      let(:endpoint) { '/api/version' }

      it 'returns the API version' do
        get endpoint

        expect(json).to eq({
          'version' => '2.0.0'
        })
      end
    end

    describe 'last update endpoint' do
      let(:endpoint) { '/api/last_update' }

      it 'returns the last update time' do
        get endpoint

        expect(json).to eq({
          'last_update' => '2020-04-14 07:30:00 +0000'
        })
      end
    end

    describe 'non-existent endpoint' do
      let(:endpoint) { '/api/non-existent' }

      it 'returns status 404' do
        get endpoint

        expect(last_response).to be_not_found
      end
    end

    describe 'server error' do
      let(:endpoint) { '/api/error' }

      before { app.before('/api/error') { raise StandardError } }

      it 'returns a 500 page' do
        get endpoint

        expect(last_response).to be_server_error
      end
    end
  end
end
