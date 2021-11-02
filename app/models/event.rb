class Event < ApplicationRecord
  has_many :registrations, dependent: :destroy
end
