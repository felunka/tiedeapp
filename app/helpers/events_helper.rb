module EventsHelper
  def resolve_recipients(event, mail_params, strategy)
    case strategy
    when 'select_members'
      member_ids = Array(mail_params[:recipients]).reject(&:blank?).map(&:to_i)
      if member_ids.empty?
        redirect_to event_path(event), flash: { danger: t('mails.errors.no_recipients') }
        return nil
      end

      ensure_member_events(event, member_ids)
      MemberEvent.where(event_id: event.id, member_id: member_ids)
                 .joins(:member)
                 .where.not(members: { email: [nil, ''] })
    when 'select_group'
      member_types = Array(mail_params[:member_groups]).reject(&:blank?)
      if member_types.empty?
        redirect_to event_path(event), flash: { danger: t('mails.errors.no_group_selected') }
        return nil
      end

      group_member_ids = Member.where(member_type: member_types).pluck(:id)
      ensure_member_events(event, group_member_ids)

      member_events = MemberEvent.where(event_id: event.id, member_id: group_member_ids)
                                 .joins(:member)
                                 .where.not(members: { email: [nil, ''] })
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

  private

  def ensure_member_events(event, member_ids)
    Array(member_ids).uniq.each do |member_id|
      MemberEvent.find_or_create_by(event_id: event.id, member_id: member_id)
    end
  end

  def send_emails_async(member_events, template, custom_text, attachments)
    Thread.new do
      member_events.find_each do |member_event|
        case template
        when 'invite'
          InviteMailer.send_invite(member_event).deliver_now
        when 'reminder'
          InviteMailer.send_reminder(member_event).deliver_now
        when 'custom'
          InviteMailer.send_custom(member_event, custom_text, attachments).deliver_now
        end
      end
    end
  end
end
