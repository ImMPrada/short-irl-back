class TemporarySession < ApplicationRecord
  MAX_TEMPORARY_SESSION_URLS = 10

  before_validation :generate_uuid, on: :create

  validates :uuid, presence: true, uniqueness: true

  has_many :registered_urls, dependent: :nullify

  validates :registered_urls, length: { maximum: MAX_TEMPORARY_SESSION_URLS }

  private

  def generate_uuid
    self.uuid = UUIDTools::UUID.timestamp_create if uuid.blank?
  end
end
