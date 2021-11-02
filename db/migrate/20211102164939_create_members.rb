class CreateMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :street
      t.string :zip
      t.string :city
      t.string :county

      t.timestamps
    end
  end
end
