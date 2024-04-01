require 'rails_helper'

RSpec.describe Api::V1::RegisteredUrlsController, type: :controller do
  let(:temporary_session) { create(:temporary_session) }

  describe 'when is not authenticated' do
    describe 'GET #index' do
      it 'returns unauthorized status' do
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'POST #create' do
      it 'returns unauthorized status' do
        post :create, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'when token is invalid' do
    before do
      request.headers['Authorization'] = "Token #{temporary_session.uuid}invalid"
    end

    describe 'GET #index' do
      it 'returns unauthorized status' do
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'POST #create' do
      it 'returns unauthorized status' do
        post :create, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'when token is valid' do
    before do
      request.headers['Authorization'] = "Token #{temporary_session.uuid}"
    end

    describe 'GET #index' do
      it 'returns success status' do
        get :index, format: :json
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'POST #create' do
      it 'returns success status' do
        post :create, params: { 'registered-url': { url: Faker::Internet.url } }, format: :json
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET #index' do
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

  describe 'POST #create' do
    before do
      request.headers['Authorization'] = "Token #{temporary_session.uuid}"
    end

    describe 'when registered URL is valid' do
      let(:params) { { 'registered-url': { url: Faker::Internet.url } } }

      it 'returns ok status' do
        post :create, params:, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'renders expected template' do
        post :create, params:, format: :json
        expect(response).to render_template(:create)
      end
    end

    describe 'when registered URL is invalid' do
      let(:params) { { 'registered-url': { url: '/this-is.not-an-url' } } }

      it 'returns unprocessable entity status' do
        post :create, params:, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the errors' do
        post :create, params:, format: :json
        expect(JSON.parse(response.body)).to include('errors')
      end
    end
  end
end
