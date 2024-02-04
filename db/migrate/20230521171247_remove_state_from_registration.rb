class RemoveStateFromRegistration < ActiveRecord::Migration[7.0]
  def change
    remove_column :registrations, :registration_state
  end
end
