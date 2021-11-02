class RegistrationsController < ApplicationController
  def new
    @token = params[:token]
    @event = Event.joins(:member_events).where(member_events: { token: @token }).first
    # TODO validate token valid and not used
    @registration = Registration.new
  end

  def create

  end
end
