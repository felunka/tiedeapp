class CreateMemberEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :member_events do |t|
      t.references :member, foreign_key: true, null: false
      t.references :event, foreign_key: true, null: false
      t.string :token

      t.timestamps
    end
  end
end
