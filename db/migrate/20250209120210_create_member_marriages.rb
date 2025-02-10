class CreateMemberMarriages < ActiveRecord::Migration[7.0]
  def change
    create_table :member_marriages do |t|
      t.references :partner_1, null: false, foreign_key: {to_table: :members}
      t.references :partner_2, null: false, foreign_key: {to_table: :members}

      t.timestamps
    end
  end
end
