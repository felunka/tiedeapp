class CreateAlbumPictures < ActiveRecord::Migration[8.1]
  def change
    create_table :album_pictures do |t|
      t.references :album, null: false, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
