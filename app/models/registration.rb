class Registration < ApplicationRecord
  has_one :member_event, dependent: :nullify
  has_one :event, through: :member_event

  has_many :registration_entries, dependent: :destroy
  accepts_nested_attributes_for :registration_entries, reject_if: :all_blank, allow_destroy: true

  validates :registration_entries, presence: true
  validate :all_double_rooms_full

  def total_price
    price = 0.0
    registration_entries.each do |entry|
      if entry.double_room?
        price += event.send("fee_#{entry.user_type}")
      elsif entry.single_room?
        price += event.send("fee_#{entry.user_type}")
        if entry.guest?
          price += event.fee_guest_single_room
        else
          price += event.fee_member_single_room
        end
      else
        if entry.guest?
          price += event.base_fee_guest
        else
          price += event.base_fee_member
        end
      end
    end
    return price
  end

  def membership_fee
    registration_entries.where(user_type: 'member').count * Rails.configuration.x.membership_fee.normal +
    registration_entries.where(user_type: 'student').count * Rails.configuration.x.membership_fee.reduced
  end

  private

  def all_double_rooms_full
    if registration_entries.map(&:accommodation).count('double_room').odd?
      errors.add(:base, I18n.t('model.registration.error.number_double_rooms_odd'))
    end
  end
end
