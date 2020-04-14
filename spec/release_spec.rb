# frozen_string_literal: true

RSpec.describe Release do
  before(:all) do
    stub_request(:get, %r{_data/releases.yml})
      .to_return(
        status:  200,
        body:    fixture('releases'),
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  it 'loads the class' do
    Release.build!
    expect(Release.all.count).to be > 5
    expect(Release).to be_a(Class)
  end
end
