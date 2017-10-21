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

ActiveRecord::Schema.define(version: 20171021011639) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "banned_ips", force: :cascade do |t|
    t.inet     "ip"
    t.datetime "created_at"
  end

  create_table "favorite_replies", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "reply_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_favorite_replies_on_post_id", using: :btree
    t.index ["reply_id"], name: "index_favorite_replies_on_reply_id", using: :btree
    t.index ["user_id"], name: "index_favorite_replies_on_user_id", using: :btree
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email"
    t.text     "body"
    t.string   "url"
    t.datetime "completed_at"
    t.integer  "completed_by_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["completed_by_id"], name: "index_feedbacks_on_completed_by_id", using: :btree
    t.index ["user_id"], name: "index_feedbacks_on_user_id", using: :btree
  end

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.index ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
    t.index ["user_id"], name: "index_friendships_on_user_id", using: :btree
  end

  create_table "invites", force: :cascade do |t|
    t.integer  "from_user_id"
    t.integer  "invited_user_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.integer  "reply_id"
    t.datetime "read_at"
    t.index ["from_user_id"], name: "index_invites_on_from_user_id", using: :btree
    t.index ["invited_user_id"], name: "index_invites_on_invited_user_id", using: :btree
    t.index ["post_id"], name: "index_invites_on_post_id", using: :btree
    t.index ["reply_id"], name: "index_invites_on_reply_id", using: :btree
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

  create_table "notices", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "notice_type"
    t.string   "title"
    t.datetime "read_at"
    t.datetime "created_at"
    t.integer  "notice_for_id"
    t.string   "url"
    t.index ["user_id"], name: "index_notices_on_user_id", using: :btree
  end

  create_table "poll_options", force: :cascade do |t|
    t.integer  "poll_id"
    t.string   "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_poll_options_on_poll_id", using: :btree
  end

  create_table "polls", force: :cascade do |t|
    t.integer  "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_polls_on_post_id", using: :btree
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
    t.integer  "reply_count"
    t.boolean  "marked_as_adult"
    t.index ["author_id"], name: "index_posts_on_author_id", using: :btree
  end

  create_table "replies", force: :cascade do |t|
    t.text     "body"
    t.integer  "author_id"
    t.boolean  "posted_anonymously"
    t.boolean  "has_questionable_text"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "post_id"
    t.datetime "removed_at"
    t.boolean  "marked_as_adult"
    t.index ["author_id"], name: "index_replies_on_author_id", using: :btree
    t.index ["post_id"], name: "index_replies_on_post_id", using: :btree
  end

  create_table "sherlocks", force: :cascade do |t|
    t.integer  "changed_by_id"
    t.string   "obj_klass"
    t.integer  "obj_id"
    t.text     "previous_attributes_raw"
    t.text     "new_attributes_raw"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["changed_by_id"], name: "index_sherlocks_on_changed_by_id", using: :btree
  end

  create_table "shouts", force: :cascade do |t|
    t.integer  "sent_from_id"
    t.integer  "sent_to_id"
    t.text     "body"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "read_at"
    t.index ["sent_from_id"], name: "index_shouts_on_sent_from_id", using: :btree
    t.index ["sent_to_id"], name: "index_shouts_on_sent_to_id", using: :btree
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.boolean  "unsubscribed"
    t.datetime "last_notified_at"
    t.index ["post_id"], name: "index_subscriptions_on_post_id", using: :btree
    t.index ["user_id"], name: "index_subscriptions_on_user_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "tag_name"
    t.integer "tags_count"
    t.text    "similar_tag_id_string"
  end

  create_table "user_poll_votes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "poll_option_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["poll_option_id"], name: "index_user_poll_votes_on_poll_option_id", using: :btree
    t.index ["user_id"], name: "index_user_poll_votes_on_user_id", using: :btree
  end

  create_table "user_profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "about"
    t.text     "grow_up"
    t.text     "live_now"
    t.text     "education"
    t.text     "subjects"
    t.text     "sports"
    t.text     "jobs"
    t.text     "hobbies"
    t.text     "causes"
    t.text     "political"
    t.text     "religion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id", using: :btree
  end

  create_table "user_settings", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "hide_adult_posts",              default: true
    t.boolean  "censor_inappropriate_language", default: true
    t.datetime "last_email_sent"
    t.boolean  "send_email_notifications",      default: true
    t.boolean  "send_reply_notifications",      default: true
    t.boolean  "default_anonymous",             default: false
    t.boolean  "friends_only",                  default: false
    t.index ["user_id"], name: "index_user_settings_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "username"
    t.datetime "last_seen_at"
    t.string   "avatar_url"
    t.datetime "verified_at"
    t.date     "date_of_birth"
    t.boolean  "has_updated_username",   default: false
    t.string   "slug"
    t.integer  "role",                   default: 0
    t.boolean  "completed_signup",       default: false
    t.boolean  "can_use_chat",           default: true
    t.datetime "banned_until"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

end
