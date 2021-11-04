class RemoveWithAccomondationFromRegistrationEntries < ActiveRecord::Migration[6.0]
  def change
    remove_column :registration_entries, :with_accomondation, after: :is_vegetarian
  end
end
