class AddMusicLinkToSongs < ActiveRecord::Migration[7.0]
  def change
    add_column :songs, :music_link, :string
  end
end
