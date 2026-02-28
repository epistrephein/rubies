# frozen_string_literal: true

RSpec.describe Rubies, :redis do
  context 'HTML' do
    let(:html) { last_response.body }

    describe 'homepage' do
      let(:endpoint) { '/' }

      it 'returns the home page' do
        get endpoint

        expect(last_response.status).to eq(200)
        expect(html).to include('API interface to Ruby versions, releases and branches')
      end
    end

    describe 'ping' do
      let(:endpoint) { '/ping' }

      it 'returns a 200 status with no body' do
        get endpoint

        expect(last_response.status).to eq(200)
        expect(html).to be_empty
      end
    end

    describe 'not found' do
      let(:endpoint) { '/non-existent' }

      it 'returns a 404 page' do
        get endpoint

        expect(last_response.status).to eq(404)
        expect(html).to include("The page you're looking for doesn't exist")
      end
    end

    describe 'server error' do
      let(:endpoint) { '/' }

      it 'returns an error page' do
        allow(REDIS).to receive(:lrange).and_raise(StandardError)

        get endpoint

        expect(last_response.status).to eq(500)
        expect(html).to include('Internal server error')
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
          'branches' => ['3.4', '3.3'],
          'latest'   => ['3.4.4', '3.3.8']
        })
      end
    end

    describe 'branch endpoint' do
      let(:endpoint) { '/api/3.3' }

      it 'returns the branch info' do
        get endpoint

        expect(json).to eq({
          'branch'       => '3.3',
          'status'       => 'normal',
          'release_date' => '2023-12-25',
          'eol_date'     => nil,
          'latest'       => '3.3.8',
          'releases'     => [
            '3.3.8', '3.3.7', '3.3.6', '3.3.5', '3.3.4',
            '3.3.3', '3.3.2', '3.3.1', '3.3.0', '3.3.0-rc1',
            '3.3.0-preview3', '3.3.0-preview2', '3.3.0-preview1'
          ]
        })
      end
    end

    describe 'release endpoint' do
      let(:endpoint) { '/api/3.3.5' }

      it 'returns the release info' do
        get endpoint

        expect(json).to eq({
          'release'      => '3.3.5',
          'branch'       => '3.3',
          'status'       => 'normal',
          'release_date' => '2024-09-03',
          'latest'       => false,
          'prerelease'   => false
        })
      end
    end

    describe 'last update endpoint' do
      let(:endpoint) { '/api/last_update' }

      it 'returns the last update time' do
        get endpoint

        expect(json).to eq({
          'last_update' => '2025-05-21 09:18:14 +0000'
        })
      end
    end

    describe 'non-existent endpoint' do
      let(:endpoint) { '/api/non-existent' }

      it 'returns status 404' do
        get endpoint

        expect(last_response.status).to eq(404)
      end
    end

    describe 'server error' do
      let(:endpoint) { '/api/normal' }

      it 'returns status 500' do
        allow(REDIS).to receive(:exists?).and_raise(StandardError)

        get endpoint

        expect(last_response.status).to eq(500)
      end
    end
  end
end
