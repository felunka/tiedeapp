class CreateEvent < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :location
      t.string :description
      t.date :event_start
      t.date :event_end
      t.date :deadline_signup
    end

    add_reference :registrations, :event, foreign_key: true, null: false, after: :id
  end
end
