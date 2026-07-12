class MakeAlbumEventOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :albums, :event_id, true
  end
end
