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

ActiveRecord::Schema.define(version: 20151005203144) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "settings", force: :cascade do |t|
    t.string "channel_type", default: "group"
    t.string "name",         default: "Standup"
    t.string "bot_id"
  end

  create_table "standups", force: :cascade do |t|
    t.string   "user_id"
    t.text     "yesterday"
    t.text     "today"
    t.text     "conflicts"
    t.string   "status",     default: "disabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string  "user_id"
    t.string  "full_name"
    t.string  "standup_status", default: "not_ready"
    t.integer "sort_order",     default: 1
    t.boolean "admin_user",     default: false
  end

end
