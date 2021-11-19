class MemberEventsController < ApplicationController
  def index
    @events = Event.select('events.*, member_events.registration_id').joins(member_events: { member: :user }).where(users: { id: current_user.id })
  end
end
