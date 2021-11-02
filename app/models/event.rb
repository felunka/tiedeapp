class Event < ApplicationRecord
  has_many :member_events
  has_many :registrations, dependent: :destroy
end
