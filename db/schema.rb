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

ActiveRecord::Schema.define(version: 20150409060633) do

  create_table "certificate_requests", force: :cascade do |t|
    t.integer  "subject_id"
    t.string   "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "certificates", force: :cascade do |t|
    t.integer  "private_key_id"
    t.integer  "subject_id",       null: false
    t.integer  "public_key_id"
    t.integer  "issuer_id"
    t.string   "chain_hash",       null: false
    t.integer  "created_by_id",    null: false
    t.integer  "updated_by_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "private_keys", force: :cascade do |t|
    t.string   "key_type",   null: false
    t.integer  "bit_length", null: false
    t.string   "curve_name"
    t.string   "thumbprint", null: false
    t.string   "pem"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "public_keys", force: :cascade do |t|
    t.integer  "subject_id",   null: false
    t.string   "body"
    t.string   "modulus_hash"
    t.datetime "not_before"
    t.datetime "not_after"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "revocation_endpoints", force: :cascade do |t|
    t.integer "public_key_id", null: false
    t.string  "endpoint",      null: false
    t.string  "uri_type",      null: false
  end

  create_table "services", force: :cascade do |t|
    t.integer  "certificate_id",  null: false
    t.string   "cert_path",       null: false
    t.string   "after_rotate",    null: false
    t.string   "deploy_strategy", null: false
    t.string   "node_group",      null: false
    t.datetime "last_deployed"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "subject_alternate_names", force: :cascade do |t|
    t.integer "certificate_id"
    t.string  "name"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "CN"
    t.string "O"
    t.string "OU"
    t.string "C"
    t.string "ST"
    t.string "L"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                  null: false
    t.string   "first_name",                             null: false
    t.string   "last_name",                              null: false
    t.binary   "password_hash",                          null: false
    t.binary   "password_salt",                          null: false
    t.boolean  "can_login",              default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
