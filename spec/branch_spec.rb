# frozen_string_literal: true

RSpec.describe Branch, :github do
  before do
    Branch.build!
    Release.build!
  end

  subject { described_class['2.5'] }

  describe '#latest' do
    it 'returns the latest version of the branch' do
      expect(subject.latest).to be_a(Release)
      expect(subject.latest.to_s).to eq('2.5.8')
    end
  end

  describe '#releases' do
    it 'returns the releases of the branch' do
      expect(subject.releases).to all(be_a(Release))
    end
  end

  describe '#to_s' do
    it 'returns the branch name as string' do
      expect(subject.to_s).to eq('2.5')
    end
  end

  describe '#to_json' do
    pending
  end

  describe '#attributes' do
    pending
  end

  describe '.[]' do
    it 'returns the branch with the matching name' do
      expect(described_class['2.5']).to be_a(Branch)
      expect(described_class['2.5'].to_s).to eq('2.5')
    end
  end

  describe '.status' do
    it 'returns the branches with the matching status' do
      expect(described_class.status('security')).to all(be_a(Branch))
      expect(described_class.status('security').first.to_s).to eq('2.5')
    end
  end

  describe '.dict_branches' do
    pending
  end

  describe '.dict_statuses' do
    pending
  end

  describe '.all' do
    it 'returns all branches' do
      expect(described_class.status('security')).to all(be_a(Branch))
    end
  end
end
