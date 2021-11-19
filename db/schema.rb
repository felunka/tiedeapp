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

ActiveRecord::Schema.define(version: 2021_11_19_142927) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "description"
    t.date "event_start"
    t.date "event_end"
    t.date "deadline_signup"
    t.decimal "fee_member", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_student", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_childen", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_guest", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_member_single_room", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_guest_single_room", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.decimal "base_fee_member", precision: 10, scale: 2, default: "0.0"
    t.decimal "base_fee_guest", precision: 10, scale: 2, default: "0.0"
  end

  create_table "member_events", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.bigint "event_id", null: false
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "registration_id"
    t.index ["event_id"], name: "index_member_events_on_event_id"
    t.index ["member_id"], name: "index_member_events_on_member_id"
    t.index ["registration_id"], name: "index_member_events_on_registration_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.string "street"
    t.string "zip"
    t.string "city"
    t.string "country"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "registration_entries", force: :cascade do |t|
    t.bigint "registration_id", null: false
    t.string "name", null: false
    t.integer "user_type", default: 0, null: false
    t.boolean "is_vegetarian"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "accommodation", default: 0, null: false
    t.boolean "with_dog"
    t.index ["registration_id"], name: "index_registration_entries_on_registration_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_role", default: 0, null: false
    t.index ["member_id"], name: "index_users_on_member_id"
  end

  add_foreign_key "member_events", "events"
  add_foreign_key "member_events", "members"
  add_foreign_key "member_events", "registrations"
  add_foreign_key "registration_entries", "registrations"
  add_foreign_key "users", "members"
end
