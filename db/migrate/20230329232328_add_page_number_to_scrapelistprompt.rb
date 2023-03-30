class AddPageNumberToScrapelistprompt < ActiveRecord::Migration[7.0]
  def change
    add_column :scrapelistprompts, :page_number, :integer
  end
end
