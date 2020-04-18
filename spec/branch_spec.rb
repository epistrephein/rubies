# frozen_string_literal: true

RSpec.describe Branch, :github do
  subject(:branch) { described_class['2.5'] }

  before(:each) do
    Branch.build!
    Release.build!
  end

  describe '#latest' do
    it 'returns the latest version of the branch' do
      expect(branch.latest).to be_a(Release)
      expect(branch.latest.to_s).to eq('2.5.8')
    end
  end

  describe '#releases' do
    it 'returns the releases of the branch' do
      expect(branch.releases).to all(be_a(Release))
    end
  end

  describe '#to_s' do
    it 'returns the branch name as string' do
      expect(branch.to_s).to eq('2.5')
    end
  end

  describe '#to_json' do
    it 'returns the branch attributes as JSON' do
      expect(branch.to_json).to eq(
        '{"branch":"2.5","status":"security","release_date":"2017-12-25",' \
        '"eol_date":"2021-03-31","latest":"2.5.8","releases":["2.5.8","2.5.7",' \
        '"2.5.6","2.5.5","2.5.4","2.5.3","2.5.2","2.5.1","2.5.0","2.5.0-rc1","2.5.0-preview1"]}'
      )
    end
  end

  describe '#attributes' do
    it 'returns the branch attributes as hash' do
      expect(branch.attributes).to eq({
        branch:       '2.5',
        status:       'security',
        release_date: Date.new(2017, 12, 25),
        eol_date:     Date.new(2021, 3, 31),
        latest:       '2.5.8',
        releases:     [
          '2.5.8', '2.5.7', '2.5.6', '2.5.5', '2.5.4', '2.5.3',
          '2.5.2', '2.5.1', '2.5.0', '2.5.0-rc1', '2.5.0-preview1'
        ]
      })
    end
  end

  describe '.[]' do
    it 'returns the branch with the matching name' do
      expect(described_class['2.5']).to be_a(described_class)
      expect(described_class['2.5'].to_s).to eq('2.5')
    end
  end

  describe '.status' do
    it 'returns the branches with the matching status' do
      expect(described_class.status('security')).to all(be_a(described_class))
      expect(described_class.status('security').first.to_s).to eq('2.5')
    end
  end

  describe '.hashmap_branches' do
    it 'returns all branches attributes as hash' do
      expect(described_class.hashmap_branches.keys).to all(be_a String)
      expect(described_class.hashmap_branches.values).to all(be_a Hash)
    end
  end

  describe '.hashmap_statuses' do
    it 'returns all statuses attributes as hash' do
      expect(described_class.hashmap_statuses.keys).to all(be_a String)
      expect(described_class.hashmap_statuses.values).to all(be_a Hash)
    end
  end

  describe '.all' do
    it 'returns all branches' do
      expect(described_class.all).to all(be_a(described_class))
    end

    context 'request timed out' do
      before do
        described_class.purge!
        stub_request(:get, %r{_data/branches.yml}).to_timeout
      end

      it 'raises Faraday::ConnectionFailed exception' do
        expect { described_class.all }.to raise_exception(Faraday::ConnectionFailed)
      end
    end

    context 'remote not found' do
      before do
        described_class.purge!
        stub_request(:get, %r{_data/branches.yml}).to_return(status: 404)
      end

      it 'raises Octokit::NotFound exception' do
        expect { described_class.all }.to raise_exception(Octokit::NotFound)
      end
    end

    context 'content malformed' do
      before do
        described_class.purge!
        stub_request(:get, %r{_data/branches.yml})
          .to_return(
            status:  200,
            body:    { content: Base64.encode64('a string'.to_yaml) }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'raises a Remote::ValidationError exception' do
        expect { described_class.all }.to raise_exception(Remote::ValidationError)
      end
    end
  end

  describe '.purge!' do
    it 'purges all cached data' do
      expect { described_class.purge! }
        .to change { described_class.instance_variable_get(:@data).class }
        .from(Array)
        .to(NilClass)
    end
  end
end
