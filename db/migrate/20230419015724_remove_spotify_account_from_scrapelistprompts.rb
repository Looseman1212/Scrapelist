class RemoveSpotifyAccountFromScrapelistprompts < ActiveRecord::Migration[7.0]
  def change
    remove_column :scrapelistprompts, :spotify_account
  end
end
