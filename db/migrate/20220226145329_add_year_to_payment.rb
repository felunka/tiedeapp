class AddYearToPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :year, :integer
  end
end
