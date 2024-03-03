# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_02_08_011529) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "diets", force: :cascade do |t|
    t.date "start_date", default: "2023-01-01", null: false
    t.date "end_date", default: "2023-01-01", null: false
    t.float "initial_weight", null: false
    t.float "target_weight", null: false
    t.float "height"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_diets_on_user_id"
  end

  create_table "meals", force: :cascade do |t|
    t.time "schedule", null: false
    t.text "description", null: false
    t.integer "meal_type", null: false
    t.bigint "diet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diet_id"], name: "index_meals_on_diet_id"
  end

  create_table "runnings", force: :cascade do |t|
    t.float "duration", null: false
    t.float "distance", null: false
    t.float "avg_pace"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "running_date", null: false
    t.index ["user_id"], name: "index_runnings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "target_pace"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weights", force: :cascade do |t|
    t.float "kg", null: false
    t.date "weight_date", default: "2023-01-01", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_weights_on_user_id"
  end

  add_foreign_key "diets", "users"
  add_foreign_key "meals", "diets"
  add_foreign_key "runnings", "users"
  add_foreign_key "weights", "users"
end
