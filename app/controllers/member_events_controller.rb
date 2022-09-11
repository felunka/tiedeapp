class MemberEventsController < ApplicationController
  def index
    @events = Event.select('events.*, member_events.registration_id').joins(member_events: { member: :user }).where(users: { id: current_user.id })

    @member_events_grid = MemberEventsGrid.new(params[:member_events_grid]) do |scope|
      scope.where(users: { id: current_user.id }).page(params[:page])
    end
  end
end
