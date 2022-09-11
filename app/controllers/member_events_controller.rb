class MemberEventsController < ApplicationController
  def index
    @member_events_grid = MemberEventsGrid.new(params[:member_events_grid]) do |scope|
      scope.where(users: { id: current_user.id }).page(params[:page])
    end
  end
end
