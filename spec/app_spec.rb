# frozen_string_literal: true

RSpec.describe 'Rubies Web' do
  it 'loads the home page' do
    get '/'
    expect(last_response).to be_ok
  end
end
