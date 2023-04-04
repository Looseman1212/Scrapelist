class AddMoreQueriesToScrapelistprompts < ActiveRecord::Migration[7.0]
  def change
    add_column :scrapelistprompts, :query_two, :string
    add_column :scrapelistprompts, :query_three, :string
    add_column :scrapelistprompts, :query_four, :string
    add_column :scrapelistprompts, :query_five, :string
  end
end
