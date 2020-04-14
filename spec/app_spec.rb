# frozen_string_literal: true

RSpec.describe 'Rubies Web', :redis do
  it 'loads the home page' do
    get '/'

    expect(last_response).to be_ok
  end

  it 'returns a 404 error' do
    get '/non-existent'

    expect(last_response.status).to be 404
  end
end
