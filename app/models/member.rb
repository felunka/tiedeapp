class Member < ApplicationRecord
  has_many :member_events
  has_many :registration_entries
  has_many :payments
  has_one :user

  enum member_type: {
    member: 0,
    student: 1,
    child: 2
  }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def full_name
    "#{first_name} #{last_name}"
  end
end
