module EventsHelper
  def resolve_recipients(event, mail_params, strategy)
    member_events = MemberEvent.where(event_id: event.id).joins(:member)
    member_events = member_events.where.not(members: { email: [nil, ''] })

    case strategy
    when 'select_members'
      member_ids = Array(mail_params[:recipients]).reject(&:blank?).map(&:to_i)
      if member_ids.empty?
        redirect_to event_path(event), flash: { danger: t('mails.errors.no_recipients') }
        return nil
      end
      member_events.where(members: { id: member_ids })
    when 'select_group'
      member_types = Array(mail_params[:member_groups]).reject(&:blank?)
      if member_types.empty?
        redirect_to event_path(event), flash: { danger: t('mails.errors.no_group_selected') }
        return nil
      end
      member_events = member_events.where(members: { member_type: member_types })
      if mail_params[:only_not_registered] == '1'
        registered_member_ids = Registration.joins(:event).where(events: { id: event.id }).pluck(:member_id)
        member_events = member_events.where.not(members: { id: registered_member_ids })
      end
      member_events
    else
      redirect_to event_path(event), flash: { danger: t('mails.errors.invalid_strategy') }
      nil
    end
  end

  def send_emails_async(member_events, template, custom_text)
    Thread.new do
      member_events.find_each do |member_event|
        case template
        when 'invite'
          InviteMailer.send_invite(member_event).deliver_now
        when 'reminder'
          InviteMailer.send_reminder(member_event).deliver_now
        when 'custom'
          InviteMailer.send_custom(member_event, custom_text).deliver_now
        end
      end
    end
  end
end
