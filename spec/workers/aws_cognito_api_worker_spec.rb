# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AwsCognitoApiWorker do
  let(:username) { 'test_user' }
  let(:user_pool_id) { 'test_pool' }
  let(:old_permissions) { %w[admin editor] }
  let(:new_permissions) { %w[viewer reporter] }

  describe '#perform' do
    it 'enqueues remove and add permission jobs' do
      worker = described_class.new

      expect(RemoveUserFromGroupWorker).to receive(:perform_async)
        .with('admin', username, user_pool_id)
      expect(RemoveUserFromGroupWorker).to receive(:perform_async)
        .with('editor', username, user_pool_id)
      expect(AddUserToGroupWorker).to receive(:perform_async)
        .with('viewer', username, user_pool_id)
      expect(AddUserToGroupWorker).to receive(:perform_async)
        .with('reporter', username, user_pool_id)

      worker.perform(username, old_permissions, new_permissions, user_pool_id)
    end

    it 'handles empty old permissions' do
      worker = described_class.new

      expect(RemoveUserFromGroupWorker).not_to receive(:perform_async)
      expect(AddUserToGroupWorker).to receive(:perform_async)
        .with('viewer', username, user_pool_id)
      expect(AddUserToGroupWorker).to receive(:perform_async)
        .with('reporter', username, user_pool_id)

      worker.perform(username, [], new_permissions, user_pool_id)
    end

    it 'handles empty new permissions' do
      worker = described_class.new

      expect(RemoveUserFromGroupWorker).to receive(:perform_async)
        .with('admin', username, user_pool_id)
      expect(RemoveUserFromGroupWorker).to receive(:perform_async)
        .with('editor', username, user_pool_id)
      expect(AddUserToGroupWorker).not_to receive(:perform_async)

      worker.perform(username, old_permissions, [], user_pool_id)
    end

    it 'handles empty old and new permissions' do
      worker = described_class.new

      expect(RemoveUserFromGroupWorker).not_to receive(:perform_async)
      expect(AddUserToGroupWorker).not_to receive(:perform_async)

      worker.perform(username, [], [], user_pool_id)
    end
  end
end
