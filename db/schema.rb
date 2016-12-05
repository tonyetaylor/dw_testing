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

ActiveRecord::Schema.define(version: 20161204224703) do

  create_table "results", force: :cascade do |t|
    t.boolean  "pass_flag"
    t.integer  "user_id"
    t.integer  "test_instance_id"
    t.integer  "test_run_id"
    t.integer  "table_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["table_id"], name: "index_results_on_table_id"
    t.index ["test_instance_id"], name: "index_results_on_test_instance_id"
    t.index ["test_run_id"], name: "index_results_on_test_run_id"
    t.index ["user_id"], name: "index_results_on_user_id"
  end

  create_table "tables", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_cases", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "expected_result"
    t.string   "sql_statement"
    t.integer  "user_id"
    t.integer  "test_suite_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["test_suite_id"], name: "index_test_cases_on_test_suite_id"
    t.index ["user_id"], name: "index_test_cases_on_user_id"
  end

  create_table "test_instances", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "expected_result"
    t.string   "sql_statement"
    t.integer  "user_id"
    t.integer  "test_run_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["test_run_id"], name: "index_test_instances_on_test_run_id"
    t.index ["user_id"], name: "index_test_instances_on_user_id"
  end

  create_table "test_runs", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["user_id"], name: "index_test_runs_on_user_id"
  end

  create_table "test_suites", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
