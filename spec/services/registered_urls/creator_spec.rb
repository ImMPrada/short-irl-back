require 'rails_helper'

RSpec.describe RegisteredUrls::Creator do
  let(:creator) { described_class.new }

  context '#create_for_temporary_session' do
    let(:temporary_session) { create(:temporary_session) }

    describe 'when url is invalid' do
      it 'raises an error' do
        expect do
          creator.create_for_temporary_session(temporary_session:, url: 'url.com')
        end.to raise_error(StandardError, 'Url is invalid')
      end
    end

    describe 'when temporary session is invalid' do
      before do
        10.times do
          temporary_session.registered_urls.create(url: Faker::Internet.url)
        end
      end

      it 'raises an error' do
        expect do
          creator.create_for_temporary_session(temporary_session:, url: Faker::Internet.url)
        end.to raise_error(StandardError, "Registered urls can't be more than 10 urls")
      end
    end

    describe 'when url and temporary_session are valid' do
      it 'increases temporary_session registered urls' do
        expect do
          creator.create_for_temporary_session(temporary_session:, url: Faker::Internet.url)
        end.to change { temporary_session.registered_urls.count }.by(1)
      end

      it 'creates a registered url' do
        registered_url = creator.create_for_temporary_session(temporary_session:, url: Faker::Internet.url)

        expect(registered_url).to be_persisted
      end
    end
  end

  context '#create_for_user' do
    let(:user) { create(:user) }

    describe 'when url is invalid' do
      it 'raises an error' do
        expect do
          creator.create_for_user(user:, url: 'url.com')
        end.to raise_error(StandardError, 'Url is invalid')
      end
    end

    describe 'when url is valid' do
      it 'creates a registered url' do
        registered_url = creator.create_for_user(user:, url: Faker::Internet.url)

        expect(registered_url).to be_persisted
      end
    end
  end
end
