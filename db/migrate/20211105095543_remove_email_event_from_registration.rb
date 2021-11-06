class RemoveEmailEventFromRegistration < ActiveRecord::Migration[6.0]
  def change
    remove_column :registrations, :email, :string, after: :id
    remove_reference :registrations, :event, index: true, foreign_key: true
  end
end
