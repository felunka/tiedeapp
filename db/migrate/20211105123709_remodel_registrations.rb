class RemodelRegistrations < ActiveRecord::Migration[6.0]
  def change
    remove_column :registrations, :single_rooms, :integer, after: :id
    remove_column :registrations, :double_rooms, :integer, after: :single_rooms
    remove_column :registrations, :with_dog, :boolean, after: :single_rooms

    add_column :registration_entries, :accommodation, :integer, null: false, default: 0, after: :user_type
    add_column :registration_entries, :with_dog, :boolean, after: :is_vegetarian
  end
end
