# frozen_string_literal: true

RSpec.describe Branch, :github do
  it 'loads the class' do
    Branch.build!
    expect(Branch.all.count).to be > 5
    expect(Branch).to be_a(Class)
  end

  describe '#latest' do
    pending
  end

  describe '#releases' do
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

  describe '.status' do
    pending
  end

  describe '.dict_branches' do
    pending
  end

  describe '.dict_statuses' do
    pending
  end

  describe '.all' do
    pending
  end
end
