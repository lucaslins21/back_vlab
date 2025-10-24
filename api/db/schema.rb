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

ActiveRecord::Schema[8.1].define(version: 2025_10_24_020020) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "authors", force: :cascade do |t|
    t.date "birth_date"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_authors_on_type"
  end

  create_table "materials", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "doi"
    t.integer "duration_minutes"
    t.string "isbn"
    t.integer "page_count"
    t.string "status", default: "rascunho", null: false
    t.string "title", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["author_id"], name: "index_materials_on_author_id"
    t.index ["doi"], name: "index_materials_on_doi", unique: true, where: "(doi IS NOT NULL)"
    t.index ["isbn"], name: "index_materials_on_isbn", unique: true, where: "(isbn IS NOT NULL)"
    t.index ["type"], name: "index_materials_on_type"
    t.index ["user_id"], name: "index_materials_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "materials", "authors"
  add_foreign_key "materials", "users"
end
