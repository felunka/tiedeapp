class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.references :registration, null: true, foreign_key: true
      t.references :member, null: true, foreign_key: true

      t.timestamps
    end
  end
end
