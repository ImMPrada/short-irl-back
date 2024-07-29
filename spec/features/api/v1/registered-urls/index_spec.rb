require 'rails_helper'

RSpec.describe 'API Endpoints', type: :request do
  context 'when the request is by a temporary session' do
    let(:temporary_session) { create(:temporary_session) }
    let(:headers) do
      {
        'Authorization' => "Token #{temporary_session.uuid}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    describe 'GET /api/v1/registered-urls' do
      describe 'when there are no registered URLs' do
        it 'returns ok status' do
          get('/api/v1/registered-urls', headers:)
          expect(response).to have_http_status(:ok)
        end

        it 'returns an empty list' do
          get('/api/v1/registered-urls', headers:)
          expect(JSON.parse(response.body)).to be_empty
        end
      end

      describe 'when there are registered URLs' do
        before do
          3.times { temporary_session.registered_urls.create(url: Faker::Internet.url) }
        end

        it 'returns ok status' do
          get('/api/v1/registered-urls', headers:)
          expect(response).to have_http_status(:ok)
        end

        it 'returns a list of registered URLs' do
          get('/api/v1/registered-urls', headers:)
          expect(JSON.parse(response.body).size).to eq(3)
        end

        it 'has the correct structure in the response body' do
          get('/api/v1/registered-urls', headers:)

          expect(JSON.parse(response.body)).to all(
            include('shortVersion', 'url', 'expiresAt')
          )
        end
      end

      describe 'when temporary session is not found' do
        let(:headers) do
          {
                  'Authorization' => 'Token not_a_valid_token',
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }
        end

        it 'returns unauthorized status' do
          get('/api/v1/registered-urls', headers:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns an error message' do
          get('/api/v1/registered-urls', headers:)
          expect(JSON.parse(response.body)['errors']).to eq('autorizacion fallida')
        end
      end
    end
  end

  context 'when the request is by a registered user' do
    let(:user) { create(:user) }
    let(:headers) do
      {
        'Authorization' => "Bearer a_jwt_token_for_user_#{user.id}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end
    before do
      allow_any_instance_of(Api::V1::RegisteredUrlsController).to receive(:current_user).and_return(user)
    end

    describe 'GET /api/v1/registered-urls' do
      it 'returns ok status' do
        get('/api/v1/registered-urls', headers:)
        expect(response).to have_http_status(:ok)
      end

      describe 'when there are registered URLs' do
        before do
          5.times { user.registered_urls.create(url: Faker::Internet.url) }
        end

        it 'returns a list of registered URLs' do
          get('/api/v1/registered-urls', headers:)
          expect(JSON.parse(response.body).size).to eq(5)
        end
      end

      describe 'when there are no registered URLs' do
        it 'returns a list of registered URLs' do
          get('/api/v1/registered-urls', headers:)
          expect(JSON.parse(response.body).size).to eq(0)
        end
      end
    end
  end
end
