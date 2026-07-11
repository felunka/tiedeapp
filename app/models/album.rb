class Album < ApplicationRecord
  belongs_to :event
  has_many :album_pictures, -> { order(created_at: :asc) }, dependent: :destroy
end
