# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveLucidity do
  it 'has a VERSION constant' do
    expect(described_class::VERSION).to match(/\d+\.\d+\.\d+/)
  end

  it 'loads the helpers namespace' do
    expect(defined?(Legion::Extensions::CognitiveLucidity::Helpers)).to be_truthy
  end

  it 'loads the runners namespace' do
    expect(defined?(Legion::Extensions::CognitiveLucidity::Runners)).to be_truthy
  end

  it 'loads the Client class' do
    expect(defined?(Legion::Extensions::CognitiveLucidity::Client)).to be_truthy
  end
end
