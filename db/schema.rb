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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130514072408) do

  create_table "blists", :force => true do |t|
    t.string   "email"
    t.integer  "service_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dlists", :force => true do |t|
    t.string   "email"
    t.integer  "service_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "globalblists", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "results", :force => true do |t|
    t.string   "email"
    t.boolean  "done"
    t.integer  "score"
    t.string   "comments"
    t.integer  "survey_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "usergroup_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.text     "email_content"
    t.integer  "team_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "servicesusers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "service_id"
    t.string   "ews_id"
    t.string   "ews_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "settings", :force => true do |t|
    t.string   "var",         :null => false
    t.text     "value"
    t.integer  "target_id",   :null => false
    t.string   "target_type", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "settings", ["target_type", "target_id", "var"], :name => "index_settings_on_target_type_and_target_id_and_var", :unique => true

  create_table "surveys", :force => true do |t|
    t.integer  "service_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teamsusers", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.string   "role",       :default => "member"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "usergroups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "team_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
