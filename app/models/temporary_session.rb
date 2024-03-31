class TemporarySession < ApplicationRecord
  before_validation :generate_uuid, on: :create

  validates :uuid, presence: true, uniqueness: true

  has_many :registered_urls, dependent: :nullify

  private

  def generate_uuid
    self.uuid = UUIDTools::UUID.timestamp_create if uuid.blank?
  end
end
