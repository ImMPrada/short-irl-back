require 'rails_helper'

RSpec.describe RegisteredUrl, type: :model do
  subject(:registered_url) { create(:registered_url) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }

    describe 'when creating a new RegisteredUrl' do
      it 'adds a UUID to the record' do
        expect(registered_url.uuid).to be_present
      end

      it 'adds an expiration date to the record' do
        expect(registered_url.expires_at).to be_present
      end

      it 'adds an active status to the record' do
        expect(registered_url.active).to be_present
      end

      it 'throws an error if UUID is not unique' do
        uuid = '123'
        create(:registered_url, uuid:)
        expect { create(:registered_url, uuid:) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:temporary_session).optional }
    it { is_expected.to have_many(:url_visits).dependent(:destroy) }
  end

  describe '#url_visits_count' do
    before do
      create_list(:url_visit, 10, registered_url:)
    end

    it 'returns the number of URL visits' do
      expect(registered_url.url_visits_count).to eq(10)
    end
  end
end
