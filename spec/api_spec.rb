# frozen_string_literal: true

RSpec.describe 'Rubies API' do
  it 'returns the API versions' do
    get '/api/version'
    expect(last_response).to be_ok
  end
end
