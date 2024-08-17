class TemporarySession < ApplicationRecord
  MAX_TEMPORARY_SESSION_URLS = 10

  before_validation :generate_uuid, on: :create

  validates :uuid, presence: true, uniqueness: true

  has_many :registered_urls, dependent: :nullify

  validates :registered_urls,
            length: { maximum: MAX_TEMPORARY_SESSION_URLS,
                      message: "can't be more than #{MAX_TEMPORARY_SESSION_URLS} urls" }

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  rescue StandardError => e
    Rails.logger.error("Error generating UUID: #{e.message}")
    raise
  end
end
