class Registration < ApplicationRecord
  attr_accessor :add_payment_amount

  after_save :create_or_update_payment

  has_one :member_event, dependent: :nullify
  has_one :event, through: :member_event
  has_one :member, through: :member_event
  has_one :payment

  has_many :registration_entries, dependent: :destroy
  accepts_nested_attributes_for :registration_entries, reject_if: :all_blank, allow_destroy: true

  has_many :registered_members, source: :member, through: :registration_entries

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

  def paid_amount
    payment.amount_payed || 0
  end

  def label
    I18n.t('model.registration.label', event_name: event.name)
  end

  private

  def create_or_update_payment
    if payment.present?
      payment.update(amount_due: total_price)
    else
      Payment.create registration: self, member: member, amount_due: total_price, amount_payed: 0.0
    end
  end

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
