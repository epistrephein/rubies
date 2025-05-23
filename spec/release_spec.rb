# frozen_string_literal: true

RSpec.describe Release, :github do
  subject(:release) { described_class['3.3.5'] }

  before(:each) do
    Branch.build!
    Release.build!
  end

  describe '#latest?' do
    it 'returns whether the release is the latest version of the branch' do
      expect(release.latest?).to be false
    end
  end

  describe '#prerelease?' do
    it 'returns whether the release is a prerelease' do
      expect(release.prerelease?).to be false
    end
  end

  describe '#branch' do
    it 'returns the branch of the release' do
      expect(release.branch).to be_a(Branch)
      expect(release.branch.to_s).to eq('3.3')
    end
  end

  describe '#status' do
    it 'returns the branch status of the release' do
      expect(release.status).to eq 'normal'
    end
  end

  describe '#to_s' do
    it 'returns the release version as string' do
      expect(release.to_s).to eq('3.3.5')
    end
  end

  describe '#to_json' do
    it 'returns the release attributes as JSON' do
      expect(release.to_json).to eq(
        '{"release":"3.3.5","branch":"3.3","status":"normal",' \
        '"release_date":"2024-09-03","latest":false,"prerelease":false}'
      )
    end
  end

  describe '#attributes' do
    it 'returns the release attributes as hash' do
      expect(release.attributes).to eq({
        release:      '3.3.5',
        branch:       '3.3',
        status:       'normal',
        release_date: Date.new(2024, 9, 3),
        latest:       false,
        prerelease:   false
      })
    end
  end

  describe '.[]' do
    it 'returns the release with the matching version' do
      expect(described_class['3.3.5']).to be_a(described_class)
      expect(described_class['3.3.5'].to_s).to eq('3.3.5')
    end
  end

  describe '.branch' do
    it 'returns the releases of a branch' do
      branch = Branch['3.3']

      expect(described_class.branch(branch)).to all(be_a(described_class))
      expect(described_class.branch(branch).first.to_s).to eq('3.3.8')
    end
  end

  describe '.hashmap_releases' do
    it 'returns all releases attributes as hash' do
      expect(described_class.hashmap_releases.keys).to all(be_a String)
      expect(described_class.hashmap_releases.values).to all(be_a Hash)
    end
  end

  describe '.sha' do
    it 'returns the commit sha of the data' do
      expect(described_class.sha).to eq('927e1c0b52c16a66878fadf5b2f1f5b0aa9f4361')
    end
  end

  describe '.all' do
    it 'returns all releases' do
      expect(described_class.all).to all(be_a(described_class))
      expect(described_class.all.first.to_s).to eq('3.5.0-preview1')
      expect(described_class.all.last.to_s).to eq('1.9.0')
    end

    context 'request timed out' do
      before do
        described_class.purge!
        stub_request(:get, %r{_data/releases.yml}).to_timeout
      end

      it 'raises Faraday::ConnectionFailed exception' do
        expect { described_class.all }.to raise_exception(Faraday::ConnectionFailed)
      end
    end

    context 'remote not found' do
      before do
        described_class.purge!
        stub_request(:get, %r{_data/releases.yml}).to_return(status: 404)
      end

      it 'raises Octokit::NotFound exception' do
        expect { described_class.all }.to raise_exception(Octokit::NotFound)
      end
    end

    context 'content malformed' do
      before do
        described_class.purge!
        stub_request(:get, %r{_data/releases.yml})
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
