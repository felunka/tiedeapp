class Member < ApplicationRecord
  has_many :member_events
  has_one :user

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def full_name
    "#{first_name} #{last_name}"
  end
end
