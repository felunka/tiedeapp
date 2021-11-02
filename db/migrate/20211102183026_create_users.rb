class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.references :member, foreign_key: true, null: false
      t.string :password_digest

      t.timestamps
    end
  end
end
