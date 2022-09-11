class Member < ApplicationRecord
  has_many :member_events
  has_many :registration_entries
  has_many :payments
  has_one :user

  after_create :invite_to_upcoming_events

  enum member_type: {
    member: 0,
    student: 1,
    child: 2,
    guest: 3
  }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, uniqueness: true
  validate :email_not_ends_with_telekom

  def invite_to_upcoming_events
    Event.where('deadline_signup > ?', Date.today).each do |event|
      MemberEvent.find_or_create_by(event: event, member: self)
    end
  end

  def membership_fee
    if member_type == :student
      return Rails.configuration.x.membership_fee.reduced
    elsif member_type == :member
      return Rails.configuration.x.membership_fee.normal
    end
    return 0
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def email_not_ends_with_telekom
    errors.add(:email, I18n.t('model.member.error.email_can_not_end_with_telekom')) if email.present? && email.end_with?('t-online.de')
  end
end
