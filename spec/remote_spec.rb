# frozen_string_literal: true

RSpec.describe Remote, :github do
  describe '.new' do
    it 'disallows instantiation' do
      expect { described_class.new }
        .to raise_exception(RuntimeError, 'abstract classes cannot be instantiated')
    end
  end
end
