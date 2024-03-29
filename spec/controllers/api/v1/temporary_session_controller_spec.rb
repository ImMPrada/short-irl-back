require 'rails_helper'

RSpec.describe Api::V1::TemporarySessionController, type: :controller do
  describe 'POST #create succeed' do
    it 'returns success status' do
      post :create
      expect(response).to have_http_status(:success)
    end

    it 'returns a temporary session token' do
      post :create
      expect(response.body).to include('token')
    end
  end

  describe 'POST #create failure' do
    before do
      allow_any_instance_of(TemporarySession).to receive(:valid?).and_return(false)
    end

    it 'returns error status' do
      post :create
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns a message' do
      post :create
      expect(response.body).to include('not created')
    end
  end
end
