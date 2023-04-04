class AddAlbumArtLinkToSongs < ActiveRecord::Migration[7.0]
  def change
    add_column :songs, :album_art, :string
  end
end
