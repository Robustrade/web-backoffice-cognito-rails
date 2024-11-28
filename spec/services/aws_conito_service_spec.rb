require 'rails_helper'

RSpec.describe AwsCognitoService do
  let(:cognito_client) { instance_double(Aws::CognitoIdentityProvider::Client) }
  let(:service) { described_class.new(group_name: 'admins', username: 'test_user') }

  before do
    allow(Aws::CognitoIdentityProvider::Client).to receive(:new).and_return(cognito_client)
  end

  describe '#create_group' do
    it 'returns success when the group is created successfully' do
      response = {
        group: {
          group_name: 'admins',
          user_pool_id: 'test_pool',
          description: 'Admin group'
        }
      }
      allow(cognito_client).to receive(:create_group).and_return(response)

      result = service.create_group('Admin group', 1)

      expect(result[:success]).to eq(true)
      expect(result[:group_name]).to eq('admins')
      expect(result[:description]).to eq('Admin group')
    end

    it 'returns an error when the creation fails' do
      allow(cognito_client).to receive(:create_group).and_raise(StandardError, 'AWS Error')

      result = service.create_group('Admin group', 1)

      expect(result[:success]).to eq(false)
      expect(result[:error]).to eq('AWS Error')
    end
  end

  describe '#manage_user' do
    it 'adds a user to a group successfully' do
      allow(cognito_client).to receive(:admin_add_user_to_group).and_return(true)

      service = described_class.new(
        action: :add_user_to_group,
        group_name: 'admins',
        username: 'test_user'
      )
      result = service.manage_user

      expect(result[:success]).to eq(true)
      expect(result[:message]).to eq('User updated successfully!')
    end

    it 'handles errors when adding a user to a group' do
      allow(cognito_client).to receive(:admin_add_user_to_group).and_raise(StandardError, 'AWS Error')

      service = described_class.new(
        action: :add_user_to_group,
        group_name: 'admins',
        username: 'test_user'
      )
      result = service.manage_user

      expect(result[:success]).to eq(false)
      expect(result[:error].message).to eq('AWS Error')
    end
  end

  describe '#fetch_username' do
    it 'returns the username when the user is found' do
      response = {
        users: [
          { username: 'test_user' }
        ]
      }
      allow(cognito_client).to receive(:list_users).and_return(response)

      resp = service.fetch_username('testuser@kulu.com')
      expect(resp[:success]).to eq(true)
      expect(resp[:username]).to eq('test_user')
    end

    it 'returns an error when the user is not found' do
      response = { users: [] }
      allow(cognito_client).to receive(:list_users).and_return(response)

      resp = service.fetch_username('testuser@kulu.com')
      expect(resp[:success]).to eq(false)
      expect(resp[:error]).to eq('User not found with the given mail')
    end
  end
end
