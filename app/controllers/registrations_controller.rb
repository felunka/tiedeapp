class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :success]

  def new
    if current_user
      @event = Event.find(params[:event_id])
      member = current_user.member
    else
      unless @token = params[:token]
        flash[:danger] = t 'model.registration.error.only_with_token'
        return
      end
      @event = Event.joins(:member_events).where(member_events: { token: @token, registration_id: nil }).first
      unless @event.present?
        flash[:danger] = t 'model.registration.error.token_already_used'
      end
      member = MemberEvent.find_by(token: @token).member
    end
    @registration = Registration.new
    @registration.registration_entries = [
      RegistrationEntry.new(
        member: member
      )
    ]
  end

  def create
    if current_user
      member_event = MemberEvent.find_by(member: current_user.member, event_id: params[:registration][:event_id])
    else
      unless member_event = MemberEvent.find_by(token: params[:registration][:token], registration_id: nil)
        flash[:danger] = t 'model.registration.error.only_with_token'
        redirect_to root_path
      end
    end

    @registration = Registration.new permit(params)
    @registration.member_event = member_event

    respond_to do |format|
      if @registration.save
        format.html { redirect_to success_registration_path(@registration) }
      else
        @event = member_event.event
        @token = member_event.token
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @registration = Registration.find params[:id]
  end

  def update
    @registration = Registration.find_by params.permit(:id)

    respond_to do |format|
      if @registration.update permit(params)
        format.html { redirect_to success_registration_path(@registration) }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def success
    @registration = Registration.find params[:id]
  end

  def invitation
    @event = Registration.find_by(params.permit(:id)).event
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'invitation',
          encoding: 'UTF-8',
          show_as_html: false,
          layout: true
      end
    end
  end

  private

  def permit(params)
    params.require(:registration).permit(registration_entries_attributes: [:id, :member_id, :name, :user_type, :accommodation, :is_vegetarian, :with_dog, :_destroy])
  end
end
