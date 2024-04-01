require 'rails_helper'

RSpec.describe Api::V1::RegisteredUrlsController, type: :controller do
  describe 'GET #index' do
    let(:temporary_session) { create(:temporary_session) }

    describe 'when is not authenticated' do
      it 'returns unauthorized status' do
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'when token is invalid' do
      before do
        request.headers['Authorization'] = "Token #{temporary_session.uuid}invalid"
      end

      it 'returns unauthorized status' do
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'when token is valid' do
      before do
        request.headers['Authorization'] = "Token #{temporary_session.uuid}"
      end

      it 'returns success status' do
        get :index, format: :json
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'when there are registered URLs' do
      let(:temporary_session) { create(:temporary_session) }

      before do
        create_list(:registered_url, 4, temporary_session:)
        create_list(:registered_url, 3, active: false, temporary_session:)
        create_list(:registered_url, 2, expires_at: 40.days.ago, temporary_session:)

        request.headers['Authorization'] = "Token #{temporary_session.uuid}"
      end

      it 'returns status ok' do
        get :index, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'renders expected template' do
        get :index, format: :json
        expect(response).to render_template(:index)
      end

      it 'returns the registered URLs' do
        get :index, format: :json
        expect(assigns(:registered_urls).count).to eq(4)
      end
    end
  end
end
