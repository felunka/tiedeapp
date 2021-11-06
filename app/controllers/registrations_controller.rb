class RegistrationsController < ApplicationController
  def new
    if current_user
      @event = Event.find(params[:event_id])
      member = current_user.member
    else
      @token = params[:token]
      @event = Event.joins(:member_events).where(member_events: { token: @token, registration_id: nil }).first
      member = MemberEvent.find_by(token: @token).member
    end
    @registration = Registration.new
    @registration.registration_entries = [
      RegistrationEntry.new(
        name: member.full_name
      )
    ]
  end

  def create
    if current_user
      @registration = Registration.create permit(params)
      member_event = MemberEvent.find_by(member: current_user.member, event_id: params[:registration][:event_id])
    else
      if MemberEvent.find_by(token: params[:registration][:token], registration_id: nil)
        @registration = Registration.create permit(params)
        member_event = MemberEvent.find_by(token: params[:registration][:token])
      else
        flash[:danger] = t 'model.registration.error.only_with_token'
        redirect_to root_path
      end
    end

    member_event.update(registration: @registration)

    if @registration.id
      redirect_to success_registration_path(@registration)
    else
      @event = member_event.event
      @token = member_event.token
      render :new
    end
  end

  def success
    @registration = Registration.find params[:id]
  end

  private

  def permit(params)
    params.require(:registration).permit(registration_entries_attributes: [:id, :name, :user_type, :accommodation, :is_vegetarian, :with_dog, :_destroy])
  end
end
