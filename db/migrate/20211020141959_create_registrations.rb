class CreateRegistrations < ActiveRecord::Migration[6.0]
  def change
    create_table :registrations do |t|
      t.string :email
      t.string :token
      t.integer :single_rooms, default: 0, null: false
      t.integer :double_rooms, default: 0, null: false
      t.boolean :with_dog, default: false

      t.timestamps
    end
  end
end
