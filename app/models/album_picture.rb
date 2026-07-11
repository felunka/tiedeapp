class AlbumPicture < ApplicationRecord
  belongs_to :album

  has_one_attached :data

  validate :data_must_be_attached

  after_destroy_commit :purge_data

  private

  def purge_data
    data.purge_later if data.attached?
  end

  def data_must_be_attached
    errors.add(:data, :blank) unless data.attached?
  end
end
