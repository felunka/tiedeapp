class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def show
    @event = Event.find params[:id]
    @entries = RegistrationEntry.joins(registration: :event).where(events: { id: @event.id })
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new permit(params)
    if @event.save
      flash[:success] = t('messages.model.created')
      redirect_to action: 'index'
    else
      render :new
    end
  end

  def edit
    @event = Event.find_by params.permit(:id)
  end

  def update
    @event = Event.find_by params.permit(:id)
    if @event.update permit(params)
      flash[:success] = t('messages.model.updated')
      redirect_to action: 'index'
    else
      render :edit
    end
  end

  def destroy
    Event.find_by(params.permit(:id)).destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to action: 'index'
  end

  def send_invites
    MemberEvent.where(event_id: params[:id]).each do |member_event|
      InviteMailer.send_invite(member_event).deliver
    end
    flash[:success] = t('model.event.invites_send')
    redirect_to event_path(params[:id])
  end

  private

  def permit(params)
    params.require(:event).permit(
      :name,
      :location,
      :description,
      :event_start,
      :event_end,
      :deadline_signup,
      :fee_member,
      :fee_student,
      :fee_childen,
      :fee_guest,
      :fee_member_single_room,
      :fee_guest_single_room,
      :base_fee_member,
      :base_fee_guest
    )
  end
end
