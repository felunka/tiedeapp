class AddPricesToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :fee_member, :decimal, precision: 10, scale: 2, default: 0
    add_column :events, :fee_student, :decimal, precision: 10, scale: 2, default: 0
    add_column :events, :fee_childen, :decimal, precision: 10, scale: 2, default: 0
    add_column :events, :fee_guest, :decimal, precision: 10, scale: 2, default: 0
    add_column :events, :fee_member_single_room, :decimal, precision: 10, scale: 2, default: 0
    add_column :events, :fee_guest_single_room, :decimal, precision: 10, scale: 2, default: 0

    add_timestamps :events, null: false, default: -> { 'NOW()' }
  end
end
