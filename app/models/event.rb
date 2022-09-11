class Event < ApplicationRecord
  include ActionView::Helpers::DateHelper

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

  def deadline_signup_in_words
    label = I18n.l deadline_signup
    if before_deadline_signup?
      label = label + " (#{distance_of_time_in_words(Date.today, deadline_signup)})"
    end
    return label
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
