class AddDeathDateToMember < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :date_of_death, :date, null: true
  end
end
