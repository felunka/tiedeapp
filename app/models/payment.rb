class Payment < ApplicationRecord
  belongs_to :registration, optional: true
  belongs_to :member

  validate :year_xor_registration
  validates_inclusion_of :year, in: 2020..2100, allow_nil: true

  scope :in_year, ->(year) { where('extract(year from created_at) = ?', year) }

  enum payment_state: {
    created: 0,
    partialy_paid: 2,
    fully_paid: 3
  }

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

  def year_xor_registration
    if !(year.nil? ^ registration.nil?)
      errors.add(:base, I18n.t('model.payment.error.only_year_xor_registration'))
    end
  end
end
