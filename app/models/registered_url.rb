class RegisteredUrl < ApplicationRecord
  before_validation :generate_fields, on: :create

  DEFAULT_EXPIRATION = 30.days

  validates :url, presence: true
  validates :uuid, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :active, inclusion: { in: [true, false] }

  belongs_to :temporary_session, optional: true
  has_many :url_visits, dependent: :destroy

  private

  def generate_fields
    self.uuid = SecureRandom.hex(3) if self.uuid.blank?
    self.active = true
    self.expires_at = Time.zone.now + DEFAULT_EXPIRATION
  end
end
