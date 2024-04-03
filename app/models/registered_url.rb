class RegisteredUrl < ApplicationRecord
  before_validation :generate_fields, on: :create

  DEFAULT_EXPIRATION = 1.month

  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :uuid, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  belongs_to :temporary_session, optional: true
  has_many :url_visits, dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :not_expired, -> { where('? < expires_at', Time.zone.now) }

  private

  def generate_fields
    self.uuid = SecureRandom.hex(3) if uuid.blank?
    self.active = true if active.nil?
    self.expires_at = DEFAULT_EXPIRATION.from_now if expires_at.blank?
  end
end
