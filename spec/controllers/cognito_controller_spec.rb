require 'rails_helper'

RSpec.describe CognitoController, type: :controller do
  let(:valid_params) do
    {
      role: {
        group_name: 'admins',
        username: 'test_user',
        description: 'Admin group',
        precedence: 1
      }
    }
  end

  let(:service_instance) { instance_double(AwsCognitoService) }

  before do
    allow(AwsCognitoService).to receive(:new).and_return(service_instance)
  end

  describe 'POST #create_role' do
    it 'renders a success response when the service returns success' do
      allow(service_instance).to receive(:create_group).and_return({ success: true })

      post :create_role, params: valid_params

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['response']).to eq({ 'success' => true })
    end

    it 'renders an error response when the service returns failure' do
      allow(service_instance).to receive(:create_group).and_return({ success: false })

      post :create_role, params: valid_params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['response']).to eq({ 'success' => false })
    end
  end

  describe 'POST #add_user_to_group' do
    it 'renders a success response when the service returns success' do
      allow(service_instance).to receive(:manage_user).and_return({ success: true, message: 'User updated successfully!' })

      post :add_user_to_group, params: valid_params

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['response']).to include('success' => true)
    end
  end

  describe 'POST #remove_user_from_group' do
    it 'renders an error response when the service returns failure' do
      allow(service_instance).to receive(:manage_user).and_return({ success: false, error: 'Some error' })

      post :remove_user_from_group, params: valid_params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['response']).to include('success' => false)
    end
  end
end
