# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_11_02_161415) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "description"
    t.date "event_start"
    t.date "event_end"
    t.date "deadline_signup"
  end

  create_table "registration_entries", force: :cascade do |t|
    t.bigint "registration_id", null: false
    t.string "name", null: false
    t.integer "user_type", default: 0, null: false
    t.boolean "is_vegetarian"
    t.boolean "with_accomondation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["registration_id"], name: "index_registration_entries_on_registration_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.string "email"
    t.string "token"
    t.integer "single_rooms", default: 0, null: false
    t.integer "double_rooms", default: 0, null: false
    t.boolean "with_dog", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "event_id", null: false
    t.index ["event_id"], name: "index_registrations_on_event_id"
  end

  add_foreign_key "registration_entries", "registrations"
  add_foreign_key "registrations", "events"
end
