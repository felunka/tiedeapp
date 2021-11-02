class CreateRegistrationEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :registration_entries do |t|
      t.references :registration, foreign_key: true, null: false
      t.string :name, null: false
      t.integer :type, null: false, default: 0
      t.boolean :is_vegetarian
      t.boolean :with_accomondation

      t.timestamps
    end
  end
end
