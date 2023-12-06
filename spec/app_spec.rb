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

    describe 'ping' do
      let(:endpoint) { '/ping' }

      it 'returns a 200 status with no body' do
        get endpoint

        expect(last_response).to be_ok
        expect(html).to be_empty
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
          'branches' => ['3.2', '3.1'],
          'latest'   => ['3.2.2', '3.1.4']
        })
      end
    end

    describe 'branch endpoint' do
      let(:endpoint) { '/api/3.2' }

      it 'returns the branch info' do
        get endpoint

        expect(json).to eq({
          'branch'       => '3.2',
          'status'       => 'normal',
          'release_date' => '2022-12-25',
          'eol_date'     => nil,
          'latest'       => '3.2.2',
          'releases'     => [
            '3.2.2', '3.2.1', '3.2.0', '3.2.0-rc1',
            '3.2.0-preview3', '3.2.0-preview2', '3.2.0-preview1'
          ]
        })
      end
    end

    describe 'release endpoint' do
      let(:endpoint) { '/api/3.2.0' }

      it 'returns the release info' do
        get endpoint

        expect(json).to eq({
          'release'      => '3.2.0',
          'branch'       => '3.2',
          'status'       => 'normal',
          'release_date' => '2022-12-25',
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
          'last_update' => '2023-12-03 11:23:35 +0000'
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
  end
end
