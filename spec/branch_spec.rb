# frozen_string_literal: true

RSpec.describe Branch do
  before(:all) do
    stub_request(:get, %r{_data/branches.yml})
      .to_return(
        status:  200,
        body:    fixture('branches'),
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  it 'loads the class' do
    Branch.build!
    expect(Branch.all.count).to be > 5
    expect(Branch).to be_a(Class)
  end
end
