class RemoveUserTypeFromRegistrationEntry < ActiveRecord::Migration[6.0]
  def change
    remove_column :registration_entries, :user_type, null: false, default: 0
  end
end
