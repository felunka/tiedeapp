class Registration < ApplicationRecord
  has_one :member_event, dependent: :nullify
  has_one :event, through: :member_event
  has_one :member, through: :member_event

  has_many :registration_entries, dependent: :destroy
  accepts_nested_attributes_for :registration_entries, reject_if: :all_blank, allow_destroy: true

  enum registration_state: {
    created: 0,
    final: 1,
    partialy_paid: 2,
    paid: 3
  }

  validates :registration_entries, presence: true
  validate :all_double_rooms_full
  validate :before_deadline

  def total_price
    price = 0.0
    registration_entries.each do |entry|
      price += entry.price
    end
    return price
  end

  def membership_fee
    registration_entries.map{ |re| re.membership_fee }.sum
  end

  private

  def all_double_rooms_full
    if registration_entries.map(&:accommodation).count('double_room').odd?
      errors.add(:base, I18n.t('model.registration.error.number_double_rooms_odd'))
    end
  end

  def before_deadline
    if member_event.event.after_deadline_signup?
      errors.add(:base, I18n.t('model.registration.error.after_event_deadline'))
    end
  end
end
