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


ActiveRecord::Schema.define(version: 2019_06_09_075322) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "appraised_units", force: :cascade do |t|
    t.integer "unit_type"
    t.string "name"
    t.integer "gender"
    t.datetime "birthday"
    t.integer "id_type"
    t.string "id_num"
    t.string "addr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "main_case_id"
    t.index ["main_case_id"], name: "index_appraised_units_on_main_case_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.integer "code"
    t.integer "area_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.index ["ancestry"], name: "index_areas_on_ancestry"
  end

  create_table "bills", force: :cascade do |t|
    t.bigint "payment_order_id"
    t.string "type"
    t.string "organization"
    t.string "address"
    t.string "code"
    t.string "bank"
    t.string "phone"
    t.index ["payment_order_id"], name: "index_bills_on_payment_order_id"
  end

  create_table "case_process_records", force: :cascade do |t|
    t.bigint "main_case_id"
    t.string "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["main_case_id"], name: "index_case_process_records_on_main_case_id"
  end

  create_table "case_talks", force: :cascade do |t|
    t.integer "user_id"
    t.string "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "main_case_id"
  end

  create_table "case_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "main_case_id"
    t.integer "pos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["main_case_id"], name: "index_case_users_on_main_case_id"
    t.index ["user_id"], name: "index_case_users_on_user_id"
  end

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

  create_table "department_docs", force: :cascade do |t|
    t.string "name"
    t.string "filename"
    t.string "doc_code"
    t.integer "case_stage"
    t.boolean "check_archived"
    t.integer "check_archived_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "doc_template_id"
    t.integer "docable_id"
    t.string "docable_type"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", limit: 200, null: false
    t.text "description"
    t.string "parent_id"
    t.string "ancestry"
    t.integer "sort_no"
    t.string "code", limit: 20, default: "0000000000", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.string "matter"
    t.string "case_types"
    t.string "abbreviation"
    t.integer "case_start_no"
    t.index ["ancestry"], name: "index_departments_on_ancestry"
    t.index ["organization_id"], name: "index_departments_on_organization_id"
    t.index ["sort_no"], name: "index_departments_on_sort_no"
  end

  create_table "doc_templates", force: :cascade do |t|
    t.string "name"
    t.string "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "identification_cycles", force: :cascade do |t|
    t.integer "day"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_identification_cycles_on_organization_id"
  end

  create_table "main_cases", force: :cascade do |t|
    t.string "serial_no"
    t.string "case_no_display"
    t.integer "user_id"
    t.datetime "accept_date"
    t.integer "case_stage"
    t.datetime "case_close_date"
    t.string "case_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_name"
    t.string "organization_name"
    t.integer "organization_id"
    t.string "anyou"
    t.integer "area_id"
    t.string "organization_phone"
    t.string "organization_addr"
    t.bigint "department_id"
    t.text "matter"
    t.text "matter_demand"
    t.text "base_info"
    t.integer "pass_user"
    t.integer "sign_user"
    t.datetime "supplement_date"
    t.string "case_property"
    t.datetime "commission_date"
    t.integer "financial_stage"
    t.integer "case_no"
    t.integer "province_id"
    t.integer "city_id"
    t.integer "district_id"
    t.integer "identification_cycle"
    t.integer "material_cycle"
    t.string "ident_users"
    t.datetime "acceptance_date"
    t.string "payer"
    t.string "payer_phone"
    t.integer "wtr_id"
    t.integer "amount"
    t.index ["department_id"], name: "index_main_cases_on_department_id"
  end

  create_table "material_cycles", force: :cascade do |t|
    t.integer "day"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_material_cycles_on_organization_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "channel"
    t.boolean "status"
    t.text "description"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.integer "code"
    t.string "desc"
    t.bigint "area_id"
    t.string "addr"
    t.string "phone"
    t.string "wechat_id"
    t.integer "org_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.string "abbreviation"
    t.integer "province_id"
    t.integer "city_id"
    t.integer "district_id"
    t.string "payee"
    t.string "open_account_bank"
    t.string "account_number"
    t.index ["ancestry"], name: "index_organizations_on_ancestry"
    t.index ["area_id"], name: "index_organizations_on_area_id"
  end

  create_table "payment_orders", force: :cascade do |t|
    t.bigint "main_case_id"
    t.string "payer"
    t.string "payer_contacts"
    t.string "payer_contacts_phone"
    t.string "consigner"
    t.string "consiggner_contacts"
    t.string "consiggner_contacts_phone"
    t.float "appraisal_cost"
    t.float "business_cost"
    t.float "appear_court_cost"
    t.float "investigation_cost"
    t.float "other_cost"
    t.float "payment_in_advance"
    t.integer "payment_type"
    t.string "payment_date"
    t.string "payment_people"
    t.integer "payment_accept_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "consult_cost"
    t.index ["main_case_id"], name: "index_payment_orders_on_main_case_id"
  end

  create_table "refund_orders", force: :cascade do |t|
    t.bigint "payment_order_id"
    t.float "appraisal_cost"
    t.float "business_cost"
    t.float "appear_court_cost"
    t.float "investigation_cost"
    t.float "consult_cost"
    t.float "other_cost"
    t.float "refund_cost"
    t.integer "payee_id"
    t.integer "refund_dealer_id"
    t.integer "refund_checker_id"
    t.index ["payment_order_id"], name: "index_refund_orders_on_payment_order_id"
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
    t.integer "r_type"
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

  create_table "transfer_docs", force: :cascade do |t|
    t.string "name"
    t.integer "num"
    t.string "traits"
    t.string "status"
    t.datetime "receive_date"
    t.string "barcode"
    t.bigint "main_case_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit"
    t.string "doc_type"
    t.index ["main_case_id"], name: "index_transfer_docs_on_main_case_id"
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
    t.string "email", limit: 100
    t.string "mobile_phone", limit: 100
    t.string "hashed_password"
    t.string "salt"
    t.integer "sort_no"
    t.string "gender", limit: 10
    t.string "address"
    t.text "memo"
    t.boolean "changed_password"
    t.string "orgnization_name", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "session_id"
    t.string "api_key"
    t.string "wechat_id"
    t.bigint "organization_id"
    t.boolean "is_locked", default: false
    t.integer "user_type"
    t.string "remember_digest"
    t.string "departments"
    t.string "department_names"
    t.string "landline"
    t.integer "province_id"
    t.integer "city_id"
    t.integer "district_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["sort_no"], name: "index_users_on_sort_no"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appraised_units", "main_cases"
  add_foreign_key "bills", "payment_orders"
  add_foreign_key "case_process_records", "main_cases"
  add_foreign_key "case_users", "main_cases"
  add_foreign_key "case_users", "users"
  add_foreign_key "departments", "organizations"
  add_foreign_key "identification_cycles", "organizations"
  add_foreign_key "main_cases", "departments"
  add_foreign_key "material_cycles", "organizations"
  add_foreign_key "organizations", "areas"
  add_foreign_key "payment_orders", "main_cases"
  add_foreign_key "refund_orders", "payment_orders"
  add_foreign_key "transfer_docs", "main_cases"
  add_foreign_key "users", "organizations"
end
