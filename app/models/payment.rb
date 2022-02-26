class Payment < ApplicationRecord
  belongs_to :registration
  belongs_to :member

  validate :member_xor_registration

  def payment_type
    if member.present?
      :member
    elsif registration.present?
      :registration
    else
      :unknown
    end
  end

  private

  def member_xor_registration
    if !(member.nil? ^ registration.member?)
      errors.add(:base, I18n.t('model.payment.error.only_member_xor_registration'))
    end
  end
end
