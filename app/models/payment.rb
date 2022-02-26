class Payment < ApplicationRecord
  belongs_to :registration
  belongs_to :member
end
