class MemberEventsController < ApplicationController
  def index
    @events = Event.joins(member_events: { member: :user }).where(users: { id: current_user.id })
  end
end
