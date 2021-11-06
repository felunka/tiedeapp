class AddBasePriceToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :base_fee_member, :decimal, precision: 10, scale: 2, default: 0, after: :fee_guest_single_room
    add_column :events, :base_fee_guest, :decimal, precision: 10, scale: 2, default: 0, after: :base_fee_member
  end
end
