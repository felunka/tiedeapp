class Member < ApplicationRecord
  attr_accessor :skip_invite

  has_many :member_events, dependent: :destroy
  has_many :registration_entries, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :member_marriages_as_partner_1, class_name: 'MemberMarriage', foreign_key: :partner_1_id, dependent: :destroy
  has_many :member_marriages_as_partner_2, class_name: 'MemberMarriage', foreign_key: :partner_2_id, dependent: :destroy

  has_many :marriages, lambda { |member|
    unscope(:where).where('partner_1_id = ? OR partner_2_id = ?', member.id, member.id)
  }, class_name: 'MemberMarriage'

  has_one :user
  belongs_to :parents_marriage, class_name: 'MemberMarriage', optional: true

  accepts_nested_attributes_for :parents_marriage, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :marriages, allow_destroy: false

  scope :visible, -> { where(hidden: false) }

  after_create :invite_to_upcoming_events, unless: :skip_invite?

  enum :member_type, {
    member: 0,
    student: 1,
    child: 2,
    guest: 3
  }
  enum :family_house_origin, {
    labehn: 0,
    seeheim: 1,
    russoschin: 2,
    sydney: 3,
    kranz: 4,
    potsdam_wannsee: 5,
    kronberg_roschau: 6,
    woyanow: 7,
    dresden: 8,
    bensheim: 9
  }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true, uniqueness: true

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

    0
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_and_status
    type_name = I18n.t("simple_form.options.defaults.member_type.#{member_type}")
    "#{full_name} (#{type_name})"
  end

  def skip_invite?
    skip_invite
  end
end
