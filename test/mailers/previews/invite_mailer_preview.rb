class InviteMailerPreview < ActionMailer::Preview
  def send_invite
    InviteMailer.send_invite(MemberEvent.first)
  end
end
