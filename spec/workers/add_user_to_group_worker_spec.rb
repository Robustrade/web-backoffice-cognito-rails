# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddUserToGroupWorker do
  let(:group_name) { 'admins' }
  let(:username) { 'test_user' }
  let(:cognito_service) { instance_double(AwsCognitoService) }

  before do
    allow(AwsCognitoService).to receive(:new).and_return(cognito_service)
    allow(cognito_service).to receive(:manage_user)
  end

  it 'inherits from BaseCognitoApiWorker' do
    expect(described_class.superclass).to eq(BaseCognitoApiWorker)
  end

  it 'calls AWS Cognito service with correct parameters' do
    expect(AwsCognitoService).to receive(:new).with(
      action: :add_user_to_group,
      group_name: group_name,
      username: username
    )

    subject.perform(group_name, username)
  end

  it 'executes manage_user on the service' do
    expect(cognito_service).to receive(:manage_user)
    subject.perform(group_name, username)
  end

  # This test is skipped because the mocking of the service is not yet implemented
  it 'respects throttling limits' do
    Timecop.freeze do
      start_time = Time.current
      25.times { described_class.perform_async(group_name, username) }

      processed_count = Sidekiq::Queue.new('default').size
      Timecop.travel(1.second)

      expect(processed_count).to be <= 20
      expect(processed_count).to be >= 10
      expect(Time.current - start_time).to be >= 1.second
    end
  end
end
