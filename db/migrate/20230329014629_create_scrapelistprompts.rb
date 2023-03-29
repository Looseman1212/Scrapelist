class CreateScrapelistprompts < ActiveRecord::Migration[7.0]
  def change
    create_table :scrapelistprompts do |t|
      t.string :spotify_account
      t.string :genre
      t.string :subgenre
      t.string :release_order
      t.integer :time_frame
      t.integer :location

      t.timestamps
    end
  end
end
