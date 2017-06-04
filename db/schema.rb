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

ActiveRecord::Schema.define(version: 20170604012728) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "user_id"
    t.boolean  "posted_anonymously"
    t.boolean  "has_questionable_text"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.integer "user_id"
    t.string  "ip"
    t.string  "country_code"
    t.string  "country_name"
    t.string  "region_code"
    t.string  "region_name"
    t.string  "city"
    t.string  "zip_code"
    t.string  "time_zone"
    t.string  "metro_code"
    t.float   "latitude"
    t.float   "longitude"
    t.index ["user_id"], name: "index_locations_on_user_id", using: :btree
  end

  create_table "post_edits", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "edited_by_id"
    t.datetime "edited_at"
    t.text     "previous_body"
    t.index ["edited_by_id"], name: "index_post_edits_on_edited_by_id", using: :btree
    t.index ["post_id"], name: "index_post_edits_on_post_id", using: :btree
  end

  create_table "post_tags", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "post_id"
    t.index ["post_id"], name: "index_post_tags_on_post_id", using: :btree
    t.index ["tag_id"], name: "index_post_tags_on_tag_id", using: :btree
  end

  create_table "post_views", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "viewed_by_id"
    t.datetime "created_at"
    t.index ["post_id"], name: "index_post_views_on_post_id", using: :btree
    t.index ["viewed_by_id"], name: "index_post_views_on_viewed_by_id", using: :btree
  end

  create_table "posts", force: :cascade do |t|
    t.text     "body"
    t.integer  "author_id"
    t.boolean  "posted_anonymously"
    t.datetime "closed_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["author_id"], name: "index_posts_on_author_id", using: :btree
  end

  create_table "report_flags", force: :cascade do |t|
    t.integer  "reported_by_id"
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "comment_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["comment_id"], name: "index_report_flags_on_comment_id", using: :btree
    t.index ["post_id"], name: "index_report_flags_on_post_id", using: :btree
    t.index ["reported_by_id"], name: "index_report_flags_on_reported_by_id", using: :btree
    t.index ["user_id"], name: "index_report_flags_on_user_id", using: :btree
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.index ["post_id"], name: "index_subscriptions_on_post_id", using: :btree
    t.index ["user_id"], name: "index_subscriptions_on_user_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "tag_name"
    t.integer "tags_count"
  end

  create_table "users", force: :cascade do |t|
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
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "username"
    t.datetime "last_seen_at"
    t.string   "avatar_url"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
