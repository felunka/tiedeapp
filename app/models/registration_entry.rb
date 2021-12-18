class RegistrationEntry < ApplicationRecord
  belongs_to :registration
  has_one :event, through: :registration

  enum user_type: {
    member: 0,
    student: 1,
    child: 2,
    guest: 3
  }

  enum accommodation: {
    double_room: 0,
    single_room: 1,
    no_accommodation: 2
  }

  def price
    price = 0
    if double_room?
      price += event.send("fee_#{user_type}")
    elsif single_room?
      price += event.send("fee_#{user_type}")
      if guest?
        price += event.fee_guest_single_room
      else
        price += event.fee_member_single_room
      end
    else
      if guest?
        price += event.base_fee_guest
      else
        price += event.base_fee_member
      end
    end
    return price
  end

  def membership_fee
    if student?
      Rails.configuration.x.membership_fee.reduced
    elsif member?
      Rails.configuration.x.membership_fee.normal
    else
      0
    end
  end
end
