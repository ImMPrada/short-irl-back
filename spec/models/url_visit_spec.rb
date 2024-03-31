require 'rails_helper'

RSpec.describe UrlVisit, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:registered_url) }
  end
end
