
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

ActiveRecord::Schema.define(version: 20190605191227) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "key_placements", force: :cascade do |t|
    t.datetime "created_at"
    t.integer "master_text_id"
    t.integer "position"
    t.datetime "updated_at"
    t.integer "view_id"
  end

  add_index "key_placements", ["master_text_id"], name: "index_key_placements_on_master_text_id", using: :btree
  add_index "key_placements", ["view_id"], name: "index_key_placements_on_view_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string "code", limit: 255
    t.datetime "created_at"
    t.string "name", limit: 255
    t.string "pluralizable_label_few", limit: 255, default: ""
    t.string "pluralizable_label_many", limit: 255, default: ""
    t.string "pluralizable_label_one", limit: 255, default: ""
    t.string "pluralizable_label_other", limit: 255, default: ""
    t.string "pluralizable_label_two", limit: 255, default: ""
    t.string "pluralizable_label_zero", limit: 255, default: ""
    t.datetime "updated_at"
  end

  create_table "localized_texts", force: :cascade do |t|
    t.text "comment", default: ""
    t.datetime "created_at"
    t.text "few", default: ""
    t.text "many", default: ""
    t.integer "master_text_id"
    t.boolean "needs_entry"
    t.boolean "needs_review", default: false
    t.text "one", default: ""
    t.text "other", default: ""
    t.integer "project_language_id", null: false
    t.datetime "translated_at"
    t.text "translated_from"
    t.text "two", default: ""
    t.datetime "updated_at"
    t.text "zero", default: ""
  end

  add_index "localized_texts", ["master_text_id"], name: "index_master_text_id", using: :btree

  create_table "master_texts", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at"
    t.string "format", default: "plain"
    t.string "key", limit: 255
    t.text "one", default: ""
    t.text "other"
    t.boolean "pluralizable", default: false
    t.integer "project_id"
    t.datetime "updated_at"
    t.integer "word_count"
  end

  add_index "master_texts", ["key", "project_id"], name: "index_master_texts_on_key_and_project_id", unique: true, using: :btree

  create_table "project_languages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "language_id", null: false
    t.integer "need_entry_count"
    t.integer "need_entry_word_count"
    t.integer "need_review_count"
    t.integer "need_review_word_count"
    t.integer "project_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_languages_users", id: false, force: :cascade do |t|
    t.integer "project_language_id", null: false
    t.integer "user_id", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.boolean "edits_master_text", default: false
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.boolean "is_administrator", default: false, null: false
    t.boolean "is_developer", default: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip", limit: 255
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token", limit: 255
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "views", force: :cascade do |t|
    t.text "comments"
    t.datetime "created_at"
    t.string "name", limit: 255
    t.integer "project_id"
    t.datetime "updated_at"
  end

  add_index "views", ["name", "project_id"], name: "index_views_on_name_and_project_id", unique: true, using: :btree
end
