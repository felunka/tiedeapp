class Payment < ApplicationRecord
  belongs_to :registration, optional: true
  belongs_to :member

  validate :not_overpayed
  validate :year_xor_registration
  validates_inclusion_of :year, in: 2020..2100, allow_nil: true

  scope :in_year, ->(year) { where('extract(year from created_at) = ?', year) }

  def payment_type
    if year.present?
      :membership_fee
    elsif registration.present?
      :registration_fee
    else
      :unknown
    end
  end

  private

  def not_overpayed
    if payment_type == :membership_fee
      amount_payed = Payment.where(member: member, year: year).sum(:amount)
      if amount_payed + amount > member.membership_fee
        errors.add(:amount, I18n.t('model.payment.error.fee_too_large', fee_open: ActiveSupport::NumberHelper.number_to_currency(member.membership_fee - amount_payed)))
      end
    elsif payment_type == :registration_fee
      amount_payed = Payment.where(registration: registration).sum(:amount)
      if amount_payed + amount > registration.total_price
        errors.add(:amount, I18n.t('model.payment.error.fee_too_large', fee_open: ActiveSupport::NumberHelper.number_to_currency(registration.total_price - amount_payed)))
      end
    end
  end

  def year_xor_registration
    if !(year.nil? ^ registration.nil?)
      errors.add(:base, I18n.t('model.payment.error.only_year_xor_registration'))
    end
  end
end
