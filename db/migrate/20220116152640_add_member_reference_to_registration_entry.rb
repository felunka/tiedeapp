class AddMemberReferenceToRegistrationEntry < ActiveRecord::Migration[6.0]
  def change
    add_reference :registration_entries, :member, null: true, foreign_key: true
  end
end
