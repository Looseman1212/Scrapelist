class AddBandcampQueryToScrapelistprompt < ActiveRecord::Migration[7.0]
  def change
    add_column :scrapelistprompts, :bandcamp_query, :string
  end
end
