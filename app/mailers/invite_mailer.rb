class InviteMailer < ApplicationMailer
  default from: Rails.configuration.x.from_email

  def send_invite(member_event)
    @member = member_event.member
    @event = member_event.event
    @token = member_event.token

    bootstrap_mail to: @member.email, subject: t('mails.invite.subject', event_title: @event.name)
  end
end
