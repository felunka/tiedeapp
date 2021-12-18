class AddRegisstrationStateToRegistration < ActiveRecord::Migration[6.0]
  def change
    add_column :registrations, :registration_state, :integer, default: 0, null: false
  end
end
