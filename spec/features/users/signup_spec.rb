require 'rails_helper'

RSpec.describe 'user signup', type: :request do
  context 'POST /signup' do
    let(:temporary_session) { create(:temporary_session) }
    let(:headers) do
      {
        'Authorization' => "Token #{temporary_session.uuid}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end
    let(:user_password) { Faker::Internet.password }
    let(:user_username) { Faker::Internet.username }
    let(:user_params) do
      {
        user: {
          email: user_mail,
          password: user_password,
          username: user_username,
          confirm_password: user_password
        }
      }
    end

    context 'when the user is successfully created' do
      let(:user_mail) { Faker::Internet.email }

      it 'returns a 200 status code' do
        post '/signup', headers:, params: user_params.to_json

        expect(response).to have_http_status(:ok)
      end

      it 'returns the user data' do
        post '/signup', headers:, params: user_params.to_json

        expect(JSON.parse(response.body)['user']).to include('email', 'username')
      end

      describe 'when the temporarysession has registered urls' do
        before do
          5.times { temporary_session.registered_urls.create(url: Faker::Internet.url) }
        end

        it 'transfers the registered urls to the user' do
          temporary_session_registered_urls = temporary_session.registered_urls.pluck(:id)
          post '/signup', headers:, params: user_params.to_json

          expect(User.last.registered_urls.pluck(:id)).to eq(temporary_session_registered_urls)
        end
      end
    end

    describe 'when the email already exists' do
      let(:user) { create(:user) }
      let(:user_mail) { user.email }

      it 'returns a 422 status code' do
        post '/signup', headers:, params: user_params.to_json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns email errors message' do
        post '/signup', headers:, params: user_params.to_json

        expect(JSON.parse(response.body)['errors']).to include('email')
      end
    end

    describe 'when email is not a valid emal' do
      let(:user_mail) { 'not_a_valid_email' }

      it 'returns a 422 status code' do
        post '/signup', headers:, params: user_params.to_json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns email errors message' do
        post '/signup', headers:, params: user_params.to_json

        expect(JSON.parse(response.body)['errors']).to include('email')
      end
    end

    describe 'when email is not provided' do
      let(:user_mail) { nil }

      it 'returns a 422 status code' do
        post '/signup', headers:, params: user_params.to_json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns email errors message' do
        post '/signup', headers:, params: user_params.to_json

        expect(JSON.parse(response.body)['errors']).to include('email')
      end
    end
  end
end
