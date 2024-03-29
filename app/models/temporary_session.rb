class TemporarySession < ApplicationRecord
  before_validation :generate_uuid, on: :create

  validates :uuid, presence: true, uniqueness: true

  private

  def generate_uuid
    self.uuid = UUIDTools::UUID.timestamp_create
  end
end
