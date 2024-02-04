class AddDueAmoutAndDateToPayment < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :due_date, :date
    rename_column :payments, :amount, :amount_due
    add_column :payments, :amount_payed, :decimal, default: 0.0, null: false
    add_column :payments, :payment_state, :integer, default: 0, null: false
  end
end
