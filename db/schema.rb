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

ActiveRecord::Schema.define(version: 20150701132441) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "key_placements", force: true do |t|
    t.integer  "master_text_id"
    t.integer  "view_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "key_placements", ["master_text_id"], name: "index_key_placements_on_master_text_id", using: :btree
  add_index "key_placements", ["view_id"], name: "index_key_placements_on_view_id", using: :btree

  create_table "languages", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pluralizable_label_zero",  default: ""
    t.string   "pluralizable_label_one",   default: ""
    t.string   "pluralizable_label_two",   default: ""
    t.string   "pluralizable_label_few",   default: ""
    t.string   "pluralizable_label_many",  default: ""
    t.string   "pluralizable_label_other", default: ""
  end

  create_table "languages_users", id: false, force: true do |t|
    t.integer "language_id", null: false
    t.integer "user_id",     null: false
  end

  add_index "languages_users", ["language_id", "user_id"], name: "index_languages_users_on_language_id_and_user_id", using: :btree
  add_index "languages_users", ["user_id", "language_id"], name: "index_languages_users_on_user_id_and_language_id", using: :btree

  create_table "localized_texts", force: true do |t|
    t.integer  "master_text_id"
    t.integer  "language_id"
    t.text     "other",          default: ""
    t.text     "comment",        default: ""
    t.boolean  "needs_review",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "zero",           default: ""
    t.text     "one",            default: ""
    t.text     "two",            default: ""
    t.text     "few",            default: ""
    t.text     "many",           default: ""
    t.boolean  "needs_entry"
  end

  add_index "localized_texts", ["language_id", "master_text_id"], name: "index_language_id_master_text_id_unqiue", unique: true, using: :btree
  add_index "localized_texts", ["language_id"], name: "index_language_id", using: :btree
  add_index "localized_texts", ["master_text_id"], name: "index_master_text_id", using: :btree

  create_table "master_texts", force: true do |t|
    t.string   "key"
    t.text     "other"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pluralizable", default: false
    t.text     "one",          default: ""
    t.integer  "project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end


  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_administrator",       default: false, null: false
    t.boolean  "is_developer",           default: false
    t.boolean  "edits_master_text",      default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "views", force: true do |t|
    t.string   "name"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

end
