class AddPaidAmountToRegistration < ActiveRecord::Migration[6.0]
  def change
    add_column :registrations, :paid_amount, :decimal, precision: 10, scale: 2, default: 0, after: :registration_state
  end
end
