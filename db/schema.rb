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

ActiveRecord::Schema[8.1].define(version: 2026_07_11_101711) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "album_pictures", force: :cascade do |t|
    t.bigint "album_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "updated_at", null: false
    t.index ["album_id"], name: "index_album_pictures_on_album_id"
  end

  create_table "albums", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.bigint "event_id", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_albums_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.decimal "base_fee_guest", precision: 10, scale: 2, default: "0.0"
    t.decimal "base_fee_member", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.date "deadline_signup"
    t.string "description"
    t.date "event_end"
    t.date "event_start"
    t.decimal "fee_child", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_guest", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_guest_single_room", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_member", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_member_single_room", precision: 10, scale: 2, default: "0.0"
    t.decimal "fee_student", precision: 10, scale: 2, default: "0.0"
    t.string "location"
    t.string "name"
    t.datetime "updated_at", default: -> { "now()" }, null: false
  end

  create_table "member_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.integer "member_id", null: false
    t.bigint "registration_id"
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_member_events_on_event_id"
    t.index ["member_id"], name: "index_member_events_on_member_id"
    t.index ["registration_id"], name: "index_member_events_on_registration_id"
  end

  create_table "member_marriages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "partner_1_id", null: false
    t.bigint "partner_2_id", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_1_id"], name: "index_member_marriages_on_partner_1_id"
    t.index ["partner_2_id"], name: "index_member_marriages_on_partner_2_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "city"
    t.string "country", default: "DE"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.date "date_of_death"
    t.string "email"
    t.integer "family_house_origin"
    t.string "family_tree_comment"
    t.string "first_name"
    t.boolean "hidden", default: false
    t.string "last_name", default: "von Tiedemann"
    t.integer "member_type", default: 0, null: false
    t.bigint "parents_marriage_id"
    t.string "phone"
    t.string "street"
    t.datetime "updated_at", null: false
    t.string "zip"
    t.index ["parents_marriage_id"], name: "index_members_on_parents_marriage_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount_due"
    t.decimal "amount_payed", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.date "due_date"
    t.integer "member_id"
    t.integer "payment_state", default: 0, null: false
    t.integer "registration_id"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["member_id"], name: "index_payments_on_member_id"
    t.index ["registration_id"], name: "index_payments_on_registration_id"
  end

  create_table "registration_entries", force: :cascade do |t|
    t.integer "accommodation", default: 0, null: false
    t.datetime "created_at", null: false
    t.boolean "is_vegetarian"
    t.bigint "member_id"
    t.string "name", null: false
    t.integer "registration_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "with_dog"
    t.index ["member_id"], name: "index_registration_entries_on_member_id"
    t.index ["registration_id"], name: "index_registration_entries_on_registration_id"
  end

  create_table "registrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "member_id", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.integer "user_role", default: 0, null: false
    t.index ["member_id"], name: "index_users_on_member_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "album_pictures", "albums"
  add_foreign_key "albums", "events"
  add_foreign_key "member_events", "events"
  add_foreign_key "member_events", "members"
  add_foreign_key "member_events", "registrations"
  add_foreign_key "member_marriages", "members", column: "partner_1_id"
  add_foreign_key "member_marriages", "members", column: "partner_2_id"
  add_foreign_key "members", "member_marriages", column: "parents_marriage_id"
  add_foreign_key "payments", "members"
  add_foreign_key "payments", "registrations"
  add_foreign_key "registration_entries", "members"
  add_foreign_key "registration_entries", "registrations"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "users", "members"
end
