class RegistrationEntry < ApplicationRecord
  has_many :payments
  belongs_to :registration
  belongs_to :member, optional: true
  has_one :event, through: :registration

  enum accommodation: {
    double_room: 0,
    single_room: 1,
    no_accommodation: 2
  }

  validate :member_xor_name
  validates_uniqueness_of :member, scope: :registration_id

  def user_type
    if member
      member.member_type
    else
      :guest
    end
  end

  def price
    price = 0
    if double_room?
      price += event.send("fee_#{user_type}")
    elsif single_room?
      price += event.send("fee_#{user_type}")
      if member.nil?
        price += event.fee_guest_single_room
      else
        price += event.fee_member_single_room
      end
    else
      if member.nil?
        price += event.base_fee_guest
      else
        price += event.base_fee_member
      end
    end
    return price
  end

  def membership_fee
    return 0 if member.nil?

    payment_amount = Payment.where(member: member, year: event.event_start.year).sum(:amount)

    member.membership_fee - payment_amount
  end

  def full_name
    if member.nil?
      name
    else
      member.full_name
    end
  end

  private

  def member_xor_name
    if !(member.nil? ^ name.blank?)
      errors.add(:name, I18n.t('model.registration_entry.error.only_member_xor_name'))
    end
  end
end
