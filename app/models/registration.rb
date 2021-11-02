class Registration < ApplicationRecord
  belongs_to :event

  has_many :registration_entries, dependent: :destroy
  accepts_nested_attributes_for :registration_entries, reject_if: :all_blank, allow_destroy: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :registration_entries, presence: true
end
