# frozen_string_literal: true

RSpec.describe Release, :github do
  subject(:release) { described_class['2.6.4'] }

  before do
    Branch.build!
    Release.build!
  end

  describe '#latest?' do
    pending
  end

  describe '#prerelease?' do
    pending
  end

  describe '#branch' do
    pending
  end

  describe '#status' do
    pending
  end

  describe '#to_s' do
    pending
  end

  describe '#to_json' do
    pending
  end

  describe '#attributes' do
    pending
  end

  describe '.[]' do
    pending
  end

  describe '.branch' do
    pending
  end

  describe '.hashmap_releases' do
    pending
  end

  describe '.all' do
    pending
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
