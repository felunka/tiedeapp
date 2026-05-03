class EventsController < ApplicationController
  include EventsHelper
  def index
    @events_grid = EventsGrid.new(params[:events_grid]) do |scope|
      scope.page(params[:page])
    end
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
    respond_to do |format|
      if @event.save
        flash[:success] = t('messages.model.created')
        format.html { redirect_to action: 'index' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @event = Event.find_by params.permit(:id)
  end

  def update
    @event = Event.find_by params.permit(:id)
    respond_to do |format|
      if @event.update permit(params)
        flash[:success] = t('messages.model.updated')
        format.html { redirect_to action: 'index' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    Event.find_by(params.permit(:id)).destroy
    flash[:danger] = t('messages.model.deleted')
    redirect_to action: 'index'
  end

  def send_email
    @event = Event.find(params[:id])
    mail_params = params.require(:mail_job).permit(:template, :custom_text, :recipient_selection_strategy,
                                                   :only_not_registered, recipients: [], member_groups: [])

    template = mail_params[:template]
    strategy = mail_params[:recipient_selection_strategy]

    unless %w[invite reminder custom].include?(template)
      return redirect_to event_path(@event), flash: { danger: t('mails.errors.invalid_template') }
    end

    if template == 'custom' && mail_params[:custom_text].blank?
      return redirect_to event_path(@event), flash: { danger: t('mails.errors.custom_text_blank') }
    end

    member_events = resolve_recipients(@event, mail_params, strategy)
    return if member_events.nil?

    if member_events.none?
      return redirect_to event_path(@event), flash: { warning: t('mails.errors.no_matching_recipients') }
    end

    send_emails_async(member_events, template, mail_params[:custom_text])

    flash[:success] = t('model.event.invites_send')
    redirect_to event_path(@event)
  end

  def generate_invite_pdf
    @event = Event.find params[:id]

    members = Member.select(%(
      json_agg(jsonb_build_object('first_name', first_name, 'last_name', last_name)) AS names,
      json_agg(jsonb_build_object('full_name', CONCAT(first_name, ' ', last_name), 'token', member_events.token)) AS tokens,
      street,
      zip,
      city,
      country
    )).joins(:member_events).where(member_events: { event_id: @event.id }).group(:street, :zip, :city, :country).to_a

    @recipients = members.map do |member|
      names = member.names.group_by do |e|
        e['last_name']
      end.map { |last_name, first_names| "#{first_names.pluck('first_name').to_sentence} #{last_name}" }
      {
        recipient: names.join('\n'),
        street: member.street,
        postalcode: member.zip,
        city: member.city,
        country: ISO3166::Country[member.country],
        tokens: member.tokens
      }
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'invitation_letter.pdf',
               template: 'events/invitation_letter',
               header: {
                 html: {
                   template: 'layouts/header',
                   layout: 'layouts/application'
                 }
               },
               encoding: 'UTF-8',
               show_as_html: false,
               layout: true,
               margin: {
                 top: 10
               }
      end
    end
  end

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
      :fee_child,
      :fee_guest,
      :fee_member_single_room,
      :fee_guest_single_room,
      :base_fee_member,
      :base_fee_guest
    )
  end
end
