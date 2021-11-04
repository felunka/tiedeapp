class AddRegistrationToMemberEvent < ActiveRecord::Migration[6.0]
  def change
    add_reference :member_events, :registration, foreign_key: true, null: true, after: :event_id
  end
end
