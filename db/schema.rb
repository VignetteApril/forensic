# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_23_061105) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", limit: 200, null: false
    t.text "description"
    t.string "parent_id"
    t.string "ancestry"
    t.string "brief", limit: 100
    t.integer "sort_no"
    t.string "code", limit: 20, default: "0000000000", null: false
    t.string "admin_level", limit: 100
    t.string "role_type", limit: 100
    t.string "contact"
    t.string "orgnization_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_departments_on_ancestry"
    t.index ["sort_no"], name: "index_departments_on_sort_no"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "features", force: :cascade do |t|
    t.string "name"
    t.string "controller_name"
    t.string "action_names"
    t.string "app"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller_name"], name: "index_features_on_controller_name"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "channel"
    t.string "title"
    t.string "status"
    t.string "url"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "role_features", force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "feature_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_id"], name: "index_role_features_on_feature_id"
    t.index ["role_id"], name: "index_role_features_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "orgnization_name", default: "系统"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sys_configs", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.text "desc"
    t.string "gem"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sys_logs", force: :cascade do |t|
    t.integer "user_id"
    t.text "log_content"
    t.date "log_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["log_date"], name: "index_sys_logs_on_log_date"
    t.index ["user_id"], name: "index_sys_logs_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login", limit: 50, null: false
    t.string "name", limit: 20
    t.string "id_card_no", limit: 20
    t.string "email", limit: 100
    t.string "work_phone", limit: 200
    t.string "home_phone", limit: 100
    t.string "work_fax", limit: 100
    t.string "mobile_phone", limit: 100
    t.string "email2", limit: 100
    t.string "position", limit: 100
    t.string "hashed_password"
    t.string "salt"
    t.integer "department_id"
    t.string "code", limit: 100
    t.integer "sort_no"
    t.string "english_name", limit: 100
    t.string "politics_status", limit: 20
    t.string "id_type", limit: 20
    t.string "gender", limit: 10
    t.string "marital_status", limit: 20
    t.string "top_education", limit: 20
    t.string "top_degree", limit: 20
    t.string "rank", limit: 100
    t.string "country", limit: 100
    t.string "province", limit: 100
    t.string "city", limit: 100
    t.string "zip_code", limit: 20
    t.string "address"
    t.text "memo"
    t.boolean "changed_password"
    t.string "orgnization_name", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_id"
    t.string "api_key"
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["sort_no"], name: "index_users_on_sort_no"
  end

end
