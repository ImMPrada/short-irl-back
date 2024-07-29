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

    describe 'POST /api/v1/registered-urls' do
      let(:valid_params) do
        {
          registered_url: {
            url: Faker::Internet.url
          }
        }.to_json
      end

      describe 'when the request is valid' do
        it 'returns created status' do
          post('/api/v1/registered-urls', params: valid_params, headers:)
          expect(response).to have_http_status(:created)
        end

        it 'creates a registered URL' do
          expect do
            post('/api/v1/registered-urls', params: valid_params, headers:)
          end.to change { temporary_session.registered_urls.count }.by(1)
        end

        it 'returns the created registered URL' do
          post('/api/v1/registered-urls', params: valid_params, headers:)

          expect(JSON.parse(response.body)).to include(
            'message',
            'registeredUrl'
          )
          expect(JSON.parse(response.body)['registeredUrl']).to include(
            'shortVersion',
            'url',
            'expiresAt'
          )
        end

        it 'adds the registered URL to the temporary session' do
          post('/api/v1/registered-urls', params: valid_params, headers:)
          expected_registered_url_uuid = JSON.parse(response.body)['registeredUrl']['shortVersion']

          expect(temporary_session.registered_urls.reload.last.uuid).to eq(expected_registered_url_uuid)
        end
      end

      describe 'when the request is invalid' do
        let(:invalid_params) do
          {
            registered_url: {
              url: 'invalid.com'
            }
          }.to_json
        end

        it 'returns unprocessable entity status' do
          post('/api/v1/registered-urls', params: invalid_params, headers:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns an error message' do
          post('/api/v1/registered-urls', params: invalid_params, headers:)
          expect(JSON.parse(response.body)).to include('errors')
        end

        it 'does not create a registered URL' do
          expect do
            post('/api/v1/registered-urls', params: invalid_params, headers:)
          end.not_to(change { temporary_session.registered_urls.count })
        end
      end

      describe 'when the temporary session does not exist' do
        let(:headers) do
          {
            'Authorization' => 'Token invalid_token',
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }
        end

        it 'returns unauthorized status' do
          post('/api/v1/registered-urls', params: valid_params, headers:)
          expect(response).to have_http_status(:unprocessable_entity)
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

    describe 'POST /api/v1/registered-urls' do
      let(:valid_params) do
        {
          registered_url: {
            url: Faker::Internet.url
          }
        }.to_json
      end

      it 'returns ok status' do
        post('/api/v1/registered-urls', headers:, params: valid_params)
        expect(response).to have_http_status(:created)
      end

      it 'returns a message' do
        post('/api/v1/registered-urls', headers:, params: valid_params)
        expect(JSON.parse(response.body)).to include('message')
      end

      it 'returns the created registered URL' do
        post('/api/v1/registered-urls', headers:, params: valid_params)

        expect(JSON.parse(response.body)['registeredUrl']['url']).to eq(JSON.parse(valid_params)['registered_url']['url'])
      end
    end
  end
end
