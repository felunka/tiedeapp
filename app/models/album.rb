class Album < ApplicationRecord
  belongs_to :event, optional: true
  has_many :album_pictures, -> { order(created_at: :asc) }, dependent: :destroy
end
