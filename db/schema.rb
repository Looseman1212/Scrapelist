# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_04_04_005603) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "scrapelistprompts", force: :cascade do |t|
    t.string "spotify_account"
    t.string "genre"
    t.string "subgenre"
    t.string "release_order"
    t.integer "time_frame"
    t.integer "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bandcamp_query"
    t.integer "page_number"
  end

  create_table "songs", force: :cascade do |t|
    t.string "title"
    t.string "album"
    t.string "artist"
    t.bigint "scrapelistprompt_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "album_art"
    t.index ["scrapelistprompt_id"], name: "index_songs_on_scrapelistprompt_id"
  end

  add_foreign_key "songs", "scrapelistprompts"
end
