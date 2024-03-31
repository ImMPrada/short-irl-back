require 'rails_helper'

RSpec.describe TemporarySession, type: :model do
  subject(:temporary_session) { create(:temporary_session) }
  describe 'validations' do
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
