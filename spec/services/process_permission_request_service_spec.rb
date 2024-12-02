# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessPermissionRequestService do
  let(:email) { 'testuser@kulu.com' }
  let(:file) { fixture_file_upload('test_file.xlsx') }
  let(:username) { 'test_user' }
  let(:user_pool_id) { 'test_pool' }
  let(:service) { described_class.new(email, file, user_pool_id) }
  let(:aws_cognito_service) { instance_double(AwsCognitoService) }
  let(:excel_parser) { instance_double(ExcelParser) }

  before do
    allow(AwsCognitoService).to receive(:new).and_return(aws_cognito_service)
    allow(ExcelParser).to receive(:new).and_return(excel_parser)
  end

  describe '#call' do
    context 'when processing is successful' do
      let(:old_permissions) { ['read'] }
      let(:new_permissions) { %w[read write] }

      before do
        allow(aws_cognito_service).to receive(:fetch_username)
          .and_return({ success: true, username: username })
        allow(excel_parser).to receive(:parse)
          .and_return({ success: true, old_permissions: old_permissions, new_permissions: new_permissions })
        allow(AwsCognitoApiWorker).to receive(:perform_async)
      end

      it 'processes the permission request successfully' do
        result = service.call
        expect(result[:success]).to be true
        expect(AwsCognitoApiWorker).to have_received(:perform_async)
          .with(username, old_permissions, new_permissions, user_pool_id)
      end
    end

    context 'when AWS Cognito service fails' do
      before do
        allow(aws_cognito_service).to receive(:fetch_username)
          .and_return({ success: false, error: 'User not found' })
      end

      it 'returns error response' do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:error]).to eq('User not found')
      end
    end

    context 'when Excel parsing fails' do
      before do
        allow(aws_cognito_service).to receive(:fetch_username)
          .and_return({ success: true, username: username })
        allow(excel_parser).to receive(:parse)
          .and_return({ success: false, message: 'Invalid file format' })
      end

      it 'returns error response' do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Invalid file format')
      end
    end

    context 'when file is nil' do
      let(:service) { described_class.new(email, nil, user_pool_id) }

      before do
        allow(aws_cognito_service).to receive(:fetch_username)
          .and_return({ success: true, username: username })
        allow(excel_parser).to receive(:parse)
      end

      it 'returns error response' do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:error]).to be_present
      end
    end

    context 'when email is invalid' do
      let(:service) { described_class.new('invalid-email', file, user_pool_id) }

      before do
        allow(aws_cognito_service).to receive(:fetch_username)
          .and_return({ success: false, error: 'Invalid email format' })
      end

      it 'returns error response' do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Invalid email format')
      end
    end
  end
end
