require 'rails_helper'

RSpec.describe RegisteredUrls::Transferor do
  let(:temporary_session) { create(:temporary_session) }
  let(:user) { create(:user) }

  describe '#transfer_to_user' do
    before do
      5.times do
        create(:registered_url, temporary_session:)
      end
    end

    it 'transfers the registered urls to the user' do
      described_class.new.transfer_to_user(user:, temporary_session_uuid: temporary_session.uuid)

      expect(user.registered_urls.count).to eq(5)
    end

    it 'destroys the temporary session' do
      described_class.new.transfer_to_user(user:, temporary_session_uuid: temporary_session.uuid)

      expect(TemporarySession.find_by(uuid: temporary_session.uuid)).to be_nil
    end

    describe 'when the temporary session does not exist' do
      it 'returns nil' do
        expect(described_class.new.transfer_to_user(user:, temporary_session_uuid: 'invalid')).to be_nil
      end
    end
  end
end
