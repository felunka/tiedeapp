class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create, :success]
  before_action :require_admin, only: [:admin_edit]

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

    if @registration.save
      redirect_to success_registration_path(@registration)
    else
      @event = member_event.event
      @token = member_event.token
      render :new
    end
  end

  def admin_edit
    @registration = Registration.find params[:id]
    @payments = Payment.where(registration: @registration).or(Payment.where(member: @registration.registered_members, year: @registration.event.event_start.year))
  end

  def edit
    @registration = Registration.find params[:id]
  end

  def update
    @registration = Registration.find_by params.permit(:id)

    if @registration.update permit(params)
      redirect_to success_registration_path(@registration)
    else
      render :edit
    end
  end

  def success
    @registration = Registration.find params[:id]
  end

  private

  def permit(params)
    params.require(:registration).permit(registration_entries_attributes: [:id, :member_id, :name, :user_type, :accommodation, :is_vegetarian, :with_dog, :_destroy])
  end
end
