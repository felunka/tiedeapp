class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new params.require(:event).permit(:name, :location, :description, :event_start, :event_end, :deadline_signup)
    if @event.save
      flash[:success] = 'Familientag angelegt'
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
    if @event.update params.require(:event).permit(:name, :location, :description, :event_start, :event_end, :deadline_signup)
      flash[:success] = 'Familientag aktualisiert'
      redirect_to action: 'index'
    else
      render :edit
    end
  end

  def destroy
    Event.find_by(params.permit(:id)).destroy
    flash[:danger] = 'Familientag gelöscht'
    redirect_to action: 'index'
  end
end
