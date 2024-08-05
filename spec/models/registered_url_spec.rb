require 'rails_helper'

RSpec.describe RegisteredUrl, type: :model do
  subject(:registered_url) { create(:registered_url) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }

    describe 'when validating the URL format' do
      it 'validates the URL format' do
        expect(registered_url).to be_valid
      end

      it 'throws an error if URL is not valid' do
        registered_url.url = 'invalid-url'
        expect(registered_url).not_to be_valid
      end
    end

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
    it { is_expected.to belong_to(:user).optional }
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

  describe '#active' do
    before do
      create(:registered_url, active: true)
      create(:registered_url, active: true)
      create(:registered_url, active: false)
    end

    it 'returns only active registered URLs' do
      expect(described_class.active.count).to eq(2)
    end
  end

  describe '#not_expired' do
    before do
      create(:registered_url, expires_at: 32.days.ago)
      create(:registered_url, expires_at: 1.day.from_now)
      create(:registered_url, expires_at: 1.day.from_now)
    end

    it 'returns only registered URLs that have not expired' do
      expect(described_class.not_expired.count).to eq(2)
    end
  end
end
