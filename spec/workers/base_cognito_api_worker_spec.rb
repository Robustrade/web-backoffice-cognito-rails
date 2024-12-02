# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseCognitoApiWorker do

  it 'includes Sidekiq::Worker' do
    expect(described_class.included_modules).to include(Sidekiq::Worker)
  end

  it 'includes Sidekiq::Throttled::Worker' do
    expect(described_class.included_modules).to include(Sidekiq::Throttled::Worker)
  end

  it 'sets correct queue options' do
    expect(described_class.sidekiq_options_hash['queue']).to eq(:default)
    expect(described_class.sidekiq_options_hash['retry']).to eq(5)
  end

  xit 'configures throttling with correct limits' do
    throttle_config = described_class.get_sidekiq_throttle_options
    expect(throttle_config[:concurrency][:limit]).to eq(10)
    expect(throttle_config[:threshold][:limit]).to eq(25)
    expect(throttle_config[:threshold][:period]).to eq(1.second)
  end
end
