# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151015124111) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.string "name"
    t.string "slack_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "customers", ["email"], name: "index_customers_on_email", unique: true, using: :btree
  add_index "customers", ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true, using: :btree

  create_table "settings", force: :cascade do |t|
    t.string "channel_type", default: "group"
    t.string "name",         default: "Standup"
    t.string "bot_id"
    t.string "bot_name"
    t.string "web_url"
  end

  create_table "standups", force: :cascade do |t|
    t.text     "yesterday"
    t.text     "today"
    t.text     "conflicts"
    t.string   "status",     default: "disabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "editing",    default: false
    t.integer  "channel_id"
    t.integer  "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string  "slack_id"
    t.string  "full_name"
    t.string  "standup_status", default: "not_ready"
    t.integer "sort_order",     default: 1
    t.boolean "admin_user",     default: false
    t.string  "nickname"
    t.integer "channel_id"
    t.string  "avatar_url"
    t.boolean "bot",            default: false
  end

end
