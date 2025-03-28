class Member < ApplicationRecord
  attr_accessor :skip_invite

  has_many :member_events
  has_many :registration_entries
  has_many :payments
  has_many :member_marriages_as_partner_1, class_name: 'MemberMarriage', foreign_key: :partner_1_id
  has_many :member_marriages_as_partner_2, class_name: 'MemberMarriage', foreign_key: :partner_2_id

  has_many :marriages, ->(member) {
    unscope(:where).where('partner_1_id = ? OR partner_2_id = ?', member.id, member.id)
  }, class_name: 'MemberMarriage'

  has_one :user
  belongs_to :parents_marriage, class_name: 'MemberMarriage', optional: true

  scope :visible, -> { where(hidden: false) }

  after_create :invite_to_upcoming_events, unless: :skip_invite?

  enum member_type: {
    member: 0,
    student: 1,
    child: 2,
    guest: 3
  }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, uniqueness: true
  validate :email_not_ends_with_telekom

  def parents
    [
      parents_marriage.partner_1,
      parents_marriage.partner_2
    ]
  end

  def invite_to_upcoming_events
    Event.where('deadline_signup > ?', Date.today).each do |event|
      MemberEvent.find_or_create_by(event: event, member: self)
    end
  end

  def membership_fee
    if member_type == 'student'
      return Rails.configuration.x.membership_fee.reduced
    elsif member_type == 'member'
      return Rails.configuration.x.membership_fee.normal
    end
    return 0
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_and_status
    type_name = I18n.t("simple_form.options.defaults.member_type.#{member_type}")
    "#{full_name} (#{type_name})"
  end

  def email_not_ends_with_telekom
    errors.add(:email, I18n.t('model.member.error.email_can_not_end_with_telekom')) if email.present? && email.end_with?('t-online.de')
  end

  def skip_invite?
    skip_invite
  end
end
