# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveUserFromGroupWorker do
  let(:group_name) { 'admins' }
  let(:username) { 'test_user' }
  let(:cognito_service) { instance_double(AwsCognitoService) }

  before do
    allow(AwsCognitoService).to receive(:new).and_return(cognito_service)
    allow(cognito_service).to receive(:manage_user)
  end

  it 'calls AWS Cognito service with correct parameters' do
    expect(AwsCognitoService).to receive(:new).with(
      action: :remove_user_from_group,
      group_name: group_name,
      username: username
    )

    subject.perform(group_name, username)
  end

  it 'executes manage_user on the service' do
    expect(cognito_service).to receive(:manage_user)
    subject.perform(group_name, username)
  end
end
