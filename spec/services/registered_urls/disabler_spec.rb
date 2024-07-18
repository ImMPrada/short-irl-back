require 'rails_helper'

RSpec.describe RegisteredUrls::Disabler do
  let(:temporary_session) { create(:temporary_session) }
  let(:user) { create(:user) }
  let(:registered_url) { create(:registered_url, temporary_session:) }
  let(:registered_url_user) { create(:registered_url, user:) }

  describe '#disable_for_temporary_session' do
    it 'deactivates the registered url' do
      disabler = described_class.new
      disabler.disable_for_temporary_session(temporary_session:, uuid: registered_url.uuid)

      expect(registered_url.reload.active).to eq(false)
    end

    describe 'when the registered url does not belong to the temporary session' do
      it 'raises an error' do
        disabler = described_class.new

        expect do
          disabler.disable_for_temporary_session(temporary_session:, uuid: registered_url_user.uuid)
        end.to raise_error(StandardError, described_class::URL_TEMPORARY_SESSION_ERROR)
      end
    end
  end

  describe '#disable_for_user' do
    it 'deactivates the registered url' do
      disabler = described_class.new
      disabler.disable_for_user(user:, uuid: registered_url_user.uuid)

      expect(registered_url_user.reload.active).to eq(false)
    end

    describe 'when the registered url does not belong to the user' do
      it 'raises an error' do
        disabler = described_class.new

        expect do
          disabler.disable_for_user(user:, uuid: registered_url.uuid)
        end.to raise_error(StandardError, described_class::URL_USER_ERROR)
      end
    end
  end
end
