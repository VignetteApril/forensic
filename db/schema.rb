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

ActiveRecord::Schema.define(version: 2022_01_14_163253) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: 6, null: false
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
    t.datetime "created_at", precision: 6, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "appraised_units", force: :cascade do |t|
    t.integer "unit_type"
    t.string "name"
    t.integer "gender"
    t.datetime "birthday", precision: 6
    t.integer "id_type"
    t.string "id_num"
    t.string "addr"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "main_case_id"
    t.bigint "entrust_order_id"
    t.integer "wtr_id"
    t.string "unit_contact"
    t.string "mobile_phone"
    t.string "nationality"
    t.index ["entrust_order_id"], name: "index_appraised_units_on_entrust_order_id"
    t.index ["main_case_id"], name: "index_appraised_units_on_main_case_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.integer "code"
    t.integer "area_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.index ["ancestry"], name: "index_areas_on_ancestry"
  end

  create_table "bills", force: :cascade do |t|
    t.string "organization"
    t.string "address"
    t.string "code"
    t.string "bank"
    t.string "phone"
    t.bigint "main_case_id"
    t.float "amount"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "bill_stage", default: 0
    t.string "bank_account"
    t.integer "bill_type"
    t.string "recipient"
    t.datetime "recipient_date", precision: 6
    t.index ["main_case_id"], name: "index_bills_on_main_case_id"
  end

  create_table "case_memos", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "main_case_id"
    t.string "content"
    t.integer "visibility_range"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["main_case_id"], name: "index_case_memos_on_main_case_id"
    t.index ["user_id"], name: "index_case_memos_on_user_id"
  end

  create_table "case_process_records", force: :cascade do |t|
    t.bigint "main_case_id"
    t.string "detail"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["main_case_id"], name: "index_case_process_records_on_main_case_id"
  end

  create_table "case_talks", force: :cascade do |t|
    t.integer "user_id"
    t.string "detail"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "main_case_id"
  end

  create_table "case_users", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "main_case_id"
    t.integer "pos"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["main_case_id"], name: "index_case_users_on_main_case_id"
    t.index ["user_id"], name: "index_case_users_on_user_id"
  end

  create_table "cases_basic", id: :integer, default: nil, force: :cascade do |t|
    t.string "flow_no", limit: 100, null: false
    t.string "case_no", limit: 100, null: false
    t.string "devolve_name", limit: 255, null: false
    t.integer "city", null: false
    t.string "accusers", limit: 255
    t.string "appellees", limit: 255
    t.integer "case_kind", limit: 2, null: false
    t.integer "devolve_time", null: false
    t.integer "appellate_time", null: false
    t.integer "apprase_cyc", limit: 2, null: false
    t.string "link_man", limit: 50
    t.string "link_tel", limit: 20
    t.string "link_mobile", limit: 20
    t.integer "consign_type", limit: 2, null: false
    t.string "devolve_caseno", limit: 50
    t.integer "case_cause", limit: 2, null: false
    t.integer "apprase_type", limit: 2, null: false
    t.string "apprase_details", limit: 500
    t.integer "by_apprase", limit: 2, null: false
    t.string "by_apprase_name", limit: 255
    t.string "by_linkman", limit: 50
    t.string "by_linktel", limit: 20
    t.integer "appellate_state", limit: 2, null: false
    t.string "audit_user", limit: 20
    t.integer "devolve_depart", null: false
    t.integer "state", limit: 2, null: false
    t.integer "state_time", null: false
    t.integer "charge_state", limit: 2
    t.float "charge_total"
    t.float "charge_appraise"
    t.float "charge_payed"
    t.float "charge_back"
    t.integer "uid", null: false
    t.integer "efficient_time", null: false
    t.integer "dateline", null: false
    t.date "payment_time"
    t.index ["case_no"], name: "case_no"
    t.index ["devolve_depart"], name: "devolve_depart"
    t.index ["efficient_time"], name: "efficient_time"
    t.index ["flow_no"], name: "flow_no"
    t.index ["state_time"], name: "state_time"
    t.index ["uid"], name: "uid"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: 6
    t.datetime "locked_at", precision: 6
    t.datetime "failed_at", precision: 6
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "department_docs", force: :cascade do |t|
    t.string "name"
    t.string "filename"
    t.string "doc_code"
    t.integer "case_stage"
    t.boolean "check_archived"
    t.integer "check_archived_no"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "doc_template_id"
    t.integer "docable_id"
    t.string "docable_type"
    t.boolean "is_passed", default: false
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", limit: 200, null: false
    t.text "description"
    t.string "parent_id"
    t.string "ancestry"
    t.integer "sort_no"
    t.string "code", limit: 20, default: "0000000000", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "entrust_orders", force: :cascade do |t|
    t.bigint "user_id"
    t.string "case_property"
    t.text "matter_demand"
    t.text "base_info"
    t.string "anyou"
    t.bigint "organization_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
    t.text "matter"
    t.bigint "department_id"
    t.index ["department_id"], name: "index_entrust_orders_on_department_id"
    t.index ["organization_id"], name: "index_entrust_orders_on_organization_id"
    t.index ["user_id"], name: "index_entrust_orders_on_user_id"
  end

  create_table "express_orders", force: :cascade do |t|
    t.string "receiver"
    t.string "receiver_addr"
    t.string "receiver_phone"
    t.integer "company_type"
    t.string "content"
    t.datetime "order_date", precision: 6
    t.bigint "main_case_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.string "order_num"
    t.string "case_no"
    t.string "reporter"
    t.index ["main_case_id"], name: "index_express_orders_on_main_case_id"
    t.index ["user_id"], name: "index_express_orders_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "features", force: :cascade do |t|
    t.string "name"
    t.string "controller_name"
    t.string "action_names"
    t.string "role_names"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "app"
    t.index ["controller_name"], name: "index_features_on_controller_name"
  end

  create_table "frequent_contacts", force: :cascade do |t|
    t.string "name"
    t.integer "province_id"
    t.integer "city_id"
    t.integer "district_id"
    t.integer "organization_id"
    t.string "client_name"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_addr"
  end

  create_table "identification_cycles", force: :cascade do |t|
    t.integer "day"
    t.bigint "organization_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_identification_cycles_on_organization_id"
  end

  create_table "incoming_records", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "pay_account"
    t.string "pay_person_name"
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "pay_date", precision: 6
    t.integer "pay_type"
    t.bigint "payment_order_id"
    t.bigint "organization_id"
    t.string "check_num"
    t.string "remarks"
    t.integer "claim_user_id"
    t.index ["organization_id"], name: "index_incoming_records_on_organization_id"
    t.index ["payment_order_id"], name: "index_incoming_records_on_payment_order_id"
  end

  create_table "main_cases", force: :cascade do |t|
    t.string "serial_no"
    t.string "case_no_display"
    t.integer "user_id"
    t.datetime "accept_date", precision: 6
    t.integer "case_stage"
    t.datetime "case_close_date", precision: 6
    t.string "case_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.datetime "supplement_date", precision: 6
    t.string "case_property"
    t.datetime "commission_date", precision: 6
    t.integer "financial_stage"
    t.integer "case_no"
    t.integer "province_id"
    t.integer "city_id"
    t.integer "district_id"
    t.integer "identification_cycle"
    t.integer "material_cycle"
    t.string "ident_users"
    t.datetime "acceptance_date", precision: 6
    t.integer "wtr_id"
    t.string "payer"
    t.string "payer_phone"
    t.float "amount"
    t.string "wtr_phone"
    t.bigint "entrust_order_id"
    t.datetime "filed_date", precision: 6
    t.string "appraisal_opinion"
    t.string "original_appraisal_opinion"
    t.boolean "is_repeat", default: false
    t.string "archive_location"
    t.string "payment_method"
    t.date "pay_date"
    t.string "bill_status"
    t.date "search_date"
    t.string "search_type"
    t.date "close_case_date"
    t.string "org_case_number"
    t.string "forensic_case_number"
    t.index ["department_id"], name: "index_main_cases_on_department_id"
    t.index ["entrust_order_id"], name: "index_main_cases_on_entrust_order_id"
  end

  create_table "material_cycles", force: :cascade do |t|
    t.integer "day"
    t.bigint "organization_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_material_cycles_on_organization_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "channel"
    t.boolean "status", default: false
    t.text "description"
    t.bigint "main_case_id"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["main_case_id"], name: "index_notifications_on_main_case_id"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ancestry"
    t.string "abbreviation"
    t.integer "province_id"
    t.integer "city_id"
    t.integer "district_id"
    t.string "payee"
    t.string "open_account_bank"
    t.string "account_number"
    t.string "level"
    t.boolean "is_confirm", default: true
    t.string "town"
    t.string "post_code"
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
    t.string "payment_people"
    t.integer "payment_accept_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "consult_cost"
    t.datetime "payment_date", precision: 6
    t.float "total_cost"
    t.boolean "take_bill", default: false
    t.bigint "bill_id"
    t.float "cash_pay"
    t.float "check_pay"
    t.string "check_num"
    t.float "card_pay"
    t.float "remit_pay"
    t.integer "order_stage", default: 0
    t.float "mobile_pay"
    t.index ["bill_id"], name: "index_payment_orders_on_bill_id"
    t.index ["main_case_id"], name: "index_payment_orders_on_main_case_id"
  end

  create_table "recive_express_orders", force: :cascade do |t|
    t.string "sender"
    t.integer "company_type"
    t.string "content"
    t.datetime "order_date", precision: 6
    t.string "order_num"
    t.bigint "main_case_id"
    t.bigint "user_id"
    t.string "case_no"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "reporter"
    t.string "receiver_mobile"
    t.string "receiver_phone"
    t.string "receiver_addr"
    t.integer "receiver_post_code"
    t.integer "province_id"
    t.integer "city_id"
    t.integer "district_id"
    t.string "three_segment_code"
    t.string "town"
    t.string "post_code"
    t.index ["main_case_id"], name: "index_recive_express_orders_on_main_case_id"
    t.index ["user_id"], name: "index_recive_express_orders_on_user_id"
  end

  create_table "refund_orders", force: :cascade do |t|
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
    t.float "total_cost"
    t.bigint "main_case_id"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "order_stage", default: 0
    t.string "refund_reason"
    t.string "payer"
    t.string "payer_contract"
    t.string "contract_phone"
    t.integer "paid_num"
    t.index ["main_case_id"], name: "index_refund_orders_on_main_case_id"
  end

  create_table "role_features", force: :cascade do |t|
    t.integer "role_id", null: false
    t.integer "feature_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["feature_id"], name: "index_role_features_on_feature_id"
    t.index ["role_id"], name: "index_role_features_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "r_type"
    t.integer "name"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sys_configs", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.text "desc"
    t.string "gem"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sys_logs", force: :cascade do |t|
    t.integer "user_id"
    t.text "log_content"
    t.date "log_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["log_date"], name: "index_sys_logs_on_log_date"
    t.index ["user_id"], name: "index_sys_logs_on_user_id"
  end

  create_table "transfer_docs", force: :cascade do |t|
    t.string "name"
    t.integer "num"
    t.string "traits"
    t.string "status"
    t.datetime "receive_date", precision: 6
    t.string "barcode"
    t.bigint "main_case_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "doc_type"
    t.string "unit"
    t.integer "serial_no", default: 0
    t.index ["main_case_id"], name: "index_transfer_docs_on_main_case_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.string "organization_name"
    t.integer "confirm_stage", default: 2
    t.string "form_id"
    t.string "open_id"
    t.boolean "is_ban", default: false
    t.string "ident_number"
    t.boolean "commonly_used", default: false
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["sort_no"], name: "index_users_on_sort_no"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appraised_units", "main_cases"
  add_foreign_key "bills", "main_cases"
  add_foreign_key "case_memos", "main_cases"
  add_foreign_key "case_memos", "users"
  add_foreign_key "case_process_records", "main_cases"
  add_foreign_key "case_users", "main_cases"
  add_foreign_key "case_users", "users"
  add_foreign_key "departments", "organizations"
  add_foreign_key "entrust_orders", "departments"
  add_foreign_key "entrust_orders", "organizations"
  add_foreign_key "entrust_orders", "users"
  add_foreign_key "express_orders", "main_cases"
  add_foreign_key "express_orders", "users"
  add_foreign_key "identification_cycles", "organizations"
  add_foreign_key "incoming_records", "organizations"
  add_foreign_key "incoming_records", "payment_orders"
  add_foreign_key "main_cases", "departments"
  add_foreign_key "main_cases", "entrust_orders"
  add_foreign_key "material_cycles", "organizations"
  add_foreign_key "organizations", "areas"
  add_foreign_key "payment_orders", "bills"
  add_foreign_key "payment_orders", "main_cases"
  add_foreign_key "recive_express_orders", "main_cases"
  add_foreign_key "recive_express_orders", "users"
  add_foreign_key "refund_orders", "main_cases"
  add_foreign_key "transfer_docs", "main_cases"
  add_foreign_key "users", "organizations"
end
