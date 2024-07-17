require 'rails_helper'

RSpec.describe TemporarySession, type: :model do
  subject(:temporary_session) { create(:temporary_session) }
  describe 'validations' do
    describe 'when reached the maximum number of registered urls' do
      before do
        10.times do
          temporary_session.registered_urls.create(url: 'http://example.com')
        end
      end

      it 'does not allow to create a new registered url' do
        expect(temporary_session).to be_valid
      end
    end

    describe 'when the maximum number of registered urls is exceeded' do
      before do
        11.times do
          temporary_session.registered_urls.create(url: 'http://example.com')
        end
      end

      it 'does not allow to create a new registered url' do
        expect(temporary_session).to be_invalid
      end
    end

    describe 'when creating a new TemporarySession' do
      it 'adds a UUID to the record' do
        expect(temporary_session.uuid).to be_present
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:registered_urls).dependent(:nullify) }
  end
end
