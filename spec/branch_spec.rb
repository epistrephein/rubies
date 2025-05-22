# frozen_string_literal: true

RSpec.describe Branch, :github do
  subject(:branch) { described_class['3.3'] }

  before(:each) do
    Branch.build!
    Release.build!
  end

  describe '#latest' do
    it 'returns the latest version of the branch' do
      expect(branch.latest).to be_a(Release)
      expect(branch.latest.to_s).to eq('3.3.8')
    end
  end

  describe '#releases' do
    it 'returns the releases of the branch' do
      expect(branch.releases).to all(be_a(Release))
    end
  end

  describe '#to_s' do
    it 'returns the branch name as string' do
      expect(branch.to_s).to eq('3.3')
    end
  end

  describe '#to_json' do
    it 'returns the branch attributes as JSON' do
      expect(branch.to_json).to eq(
        '{"branch":"3.3","status":"normal","release_date":"2023-12-25",' \
        '"eol_date":null,"latest":"3.3.8","releases":["3.3.8","3.3.7","3.3.6",' \
        '"3.3.5","3.3.4","3.3.3","3.3.2","3.3.1","3.3.0","3.3.0-rc1",' \
        '"3.3.0-preview3","3.3.0-preview2","3.3.0-preview1"]}'
      )
    end
  end

  describe '#attributes' do
    it 'returns the branch attributes as hash' do
      expect(branch.attributes).to eq({
        branch:       '3.3',
        status:       'normal',
        release_date: Date.new(2023, 12, 25),
        eol_date:     nil,
        latest:       '3.3.8',
        releases:     [
          '3.3.8', '3.3.7', '3.3.6', '3.3.5', '3.3.4',
          '3.3.3', '3.3.2', '3.3.1', '3.3.0', '3.3.0-rc1',
          '3.3.0-preview3', '3.3.0-preview2', '3.3.0-preview1'
        ]
      })
    end
  end

  describe '.[]' do
    it 'returns the branch with the matching name' do
      expect(described_class['3.3']).to be_a(described_class)
      expect(described_class['3.3'].to_s).to eq('3.3')
    end
  end

  describe '.status' do
    it 'returns the branches with the matching status' do
      expect(described_class.status('security')).to all(be_a(described_class))
      expect(described_class.status('security').first.to_s).to eq('3.2')
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

  describe '.examples_branches' do
    it 'returns the latest 4 branches as string' do
      expect(described_class.examples_branches).to all(be_a String)
      expect(described_class.examples_branches).to eq([
        '3.5', '3.4', '3.3', '3.2'
      ])
    end
  end

  describe '.examples_statuses' do
    it 'returns all statuses as string' do
      expect(described_class.examples_statuses).to all(be_a String)
      expect(described_class.examples_statuses).to eq([
        'normal', 'security', 'preview', 'eol'
      ])
    end
  end

  describe '.examples_releases' do
    it 'returns 6 releases of the 4 most recent branches as string' do
      expect(described_class.examples_releases).to all(be_a String)
      expect(described_class.examples_releases).to eq([
        '3.5.0-preview1', '3.4.4', '3.4.3', '3.3.8', '3.2.8', '3.1.7'
      ])
    end
  end

  describe '.sha' do
    it 'returns the commit sha of the data' do
      expect(described_class.sha).to eq('57cf7f91599b99d166fad9490e573e8abc391104')
    end
  end

  describe '.all' do
    it 'returns all branches' do
      expect(described_class.all).to all(be_a(described_class))
      expect(described_class.all.first.to_s).to eq('3.5')
      expect(described_class.all.last.to_s).to eq('1.9')
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
