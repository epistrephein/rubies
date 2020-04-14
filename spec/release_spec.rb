# frozen_string_literal: true

RSpec.describe Release, :github do
  it 'loads the class' do
    Release.build!
    expect(Release.all.count).to be > 5
    expect(Release).to be_a(Class)
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

  describe '.dict_releases' do
    pending
  end

  describe '.all' do
    pending
  end
end
