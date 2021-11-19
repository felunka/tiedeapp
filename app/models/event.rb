class Event < ApplicationRecord
  has_many :member_events, dependent: :destroy
  has_many :registrations, through: :member_events

  after_create :invite_all_members

  validate :event_start_after_deadline
  validate :event_end_after_start

  def invite_all_members
    Member.all.each do |member|
      MemberEvent.find_or_create_by(event: self, member: member)
    end
  end

  def before_deadline_signup?
    !after_deadline_signup?
  end

  def after_deadline_signup?
    deadline_signup < Date.today
  end

  private

  def event_start_after_deadline
    if deadline_signup > event_start
      errors.add(:deadline_signup, I18n.t('model.event.error.event_start_must_be_after_deadline'))
    end
  end

  def event_end_after_start
    if event_start > event_end
      errors.add(:event_start, I18n.t('model.event.error.event_end_must_be_after_start'))
    end
  end
end
