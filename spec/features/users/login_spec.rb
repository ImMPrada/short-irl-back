require 'rails_helper'

RSpec.describe 'user login', type: :request do
  context 'POST /login' do
    let(:temporary_session) { create(:temporary_session) }
    let(:headers) do
      {
        'Authorization' => "Token #{temporary_session.uuid}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end
    let(:user_mail) { Faker::Internet.email }
    let(:user_password) { Faker::Internet.password }
    let(:user_username) { Faker::Internet.username }
    let(:user_params) do
      {
        user: {
          email: user_mail,
          password: user_password,
          username: user_username
        }
      }
    end

    describe 'when the user is successfully loggedin' do
      before do
        post '/signup', headers:, params: user_params.to_json
      end

      it 'returns a 200 status code' do
        post '/login', headers:, params: user_params.to_json

        expect(response).to have_http_status(:ok)
      end

      it 'returns the user data' do
        post '/login', headers:, params: user_params.to_json

        expect(JSON.parse(response.body)['data']['user']).to include('email', 'username')
      end
    end

    describe 'when email or password is incorrect' do
      it 'returns a 422 status code' do
        post '/login', headers:, params: user_params.to_json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns email or password errors message' do
        post '/login', headers:, params: user_params.to_json

        expect(JSON.parse(response.body)['error']).to eq('Invalid Email or password.')
      end
    end
  end
end
