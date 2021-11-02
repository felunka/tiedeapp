class Registration < ApplicationRecord
  has_many :registration_entries, dependent: :destroy
  accepts_nested_attributes_for :registration_entries, reject_if: :all_blank, allow_destroy: true
end
