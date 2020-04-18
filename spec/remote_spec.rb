# frozen_string_literal: true

RSpec.describe Remote, :github do
  describe '.new' do
    it 'disallows instantiation' do
      expect { described_class.new }
        .to raise_exception(RuntimeError, 'abstract classes cannot be instantiated')
    end
  end

  describe Remote::ValidationError do
    it 'has a default message' do
      expect(described_class.new.message).to eq('schema validation failed')
    end
  end
end
