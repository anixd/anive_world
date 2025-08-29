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

ActiveRecord::Schema[7.2].define(version: 2025_08_28_211414) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "affixes", force: :cascade do |t|
    t.string "text"
    t.string "affix_type"
    t.bigint "language_id", null: false
    t.text "meaning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_affixes_on_language_id"
    t.index ["text", "language_id", "affix_type"], name: "index_affixes_on_text_and_language_id_and_affix_type", unique: true
  end

  create_table "content_entries", force: :cascade do |t|
    t.string "type", null: false
    t.string "title", null: false
    t.text "body"
    t.bigint "author_id", null: false
    t.string "slug", null: false
    t.datetime "published_at"
    t.datetime "discarded_at"
    t.string "world_date"
    t.integer "timeline_position"
    t.string "life_status"
    t.string "birth_date"
    t.string "death_date"
    t.bigint "parent_location_id"
    t.string "rule_code"
    t.bigint "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_content_entries_on_author_id"
    t.index ["discarded_at"], name: "index_content_entries_on_discarded_at"
    t.index ["language_id"], name: "index_content_entries_on_language_id"
    t.index ["parent_location_id"], name: "index_content_entries_on_parent_location_id"
    t.index ["slug"], name: "index_content_entries_on_slug", unique: true, where: "(discarded_at IS NULL)"
    t.index ["type"], name: "index_content_entries_on_type"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.bigint "parent_language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_languages_on_code", unique: true
    t.index ["name"], name: "index_languages_on_name", unique: true
    t.index ["parent_language_id"], name: "index_languages_on_parent_language_id"
  end

  create_table "lexemes", force: :cascade do |t|
    t.string "spelling"
    t.bigint "language_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_lexemes_on_language_id"
    t.index ["spelling", "language_id"], name: "index_lexemes_on_spelling_and_language_id", unique: true
  end

  create_table "notes", force: :cascade do |t|
    t.string "title", null: false
    t.text "body"
    t.bigint "author_id", null: false
    t.boolean "is_public_for_team", default: false, null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_notes_on_author_id"
    t.index ["discarded_at"], name: "index_notes_on_discarded_at"
  end

  create_table "roots", force: :cascade do |t|
    t.string "text"
    t.bigint "language_id", null: false
    t.text "meaning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_roots_on_language_id"
    t.index ["text", "language_id"], name: "index_roots_on_text_and_language_id", unique: true
  end

  create_table "shares", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "shareable_type", null: false
    t.bigint "shareable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shareable_type", "shareable_id"], name: "index_shares_on_shareable"
    t.index ["user_id", "shareable_id", "shareable_type"], name: "index_shares_on_user_and_shareable", unique: true
    t.index ["user_id"], name: "index_shares_on_user_id"
  end

  create_table "synonym_relations", force: :cascade do |t|
    t.bigint "word_id", null: false
    t.bigint "synonym_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["synonym_id"], name: "index_synonym_relations_on_synonym_id"
    t.index ["word_id", "synonym_id"], name: "index_synonym_relations_on_word_id_and_synonym_id", unique: true
    t.index ["word_id"], name: "index_synonym_relations_on_word_id"
  end

  create_table "translations", force: :cascade do |t|
    t.string "text", null: false
    t.string "language", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["text", "language"], name: "index_translations_on_text_and_language", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "firstname"
    t.string "lastname"
    t.string "displayname", null: false
    t.string "email", null: false
    t.boolean "active", default: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_token_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "word_roots", force: :cascade do |t|
    t.bigint "word_id", null: false
    t.bigint "root_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["root_id"], name: "index_word_roots_on_root_id"
    t.index ["word_id", "root_id"], name: "index_word_roots_on_word_id_and_root_id", unique: true
    t.index ["word_id"], name: "index_word_roots_on_word_id"
  end

  create_table "word_translations", force: :cascade do |t|
    t.bigint "word_id", null: false
    t.bigint "translation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["translation_id"], name: "index_word_translations_on_translation_id"
    t.index ["word_id", "translation_id"], name: "index_word_translations_on_word_id_and_translation_id", unique: true
    t.index ["word_id"], name: "index_word_translations_on_word_id"
  end

  create_table "words", force: :cascade do |t|
    t.bigint "lexeme_id", null: false
    t.string "type"
    t.text "definition"
    t.string "transcription"
    t.string "part_of_speech"
    t.text "comment"
    t.bigint "origin_type", default: 0
    t.bigint "origin_word_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lexeme_id"], name: "index_words_on_lexeme_id"
    t.index ["origin_word_id"], name: "index_words_on_origin_word_id"
    t.index ["type"], name: "index_words_on_type"
  end

  add_foreign_key "affixes", "languages"
  add_foreign_key "content_entries", "content_entries", column: "parent_location_id"
  add_foreign_key "content_entries", "languages"
  add_foreign_key "content_entries", "users", column: "author_id"
  add_foreign_key "languages", "languages", column: "parent_language_id"
  add_foreign_key "lexemes", "languages"
  add_foreign_key "notes", "users", column: "author_id"
  add_foreign_key "roots", "languages"
  add_foreign_key "shares", "users"
  add_foreign_key "synonym_relations", "words"
  add_foreign_key "synonym_relations", "words", column: "synonym_id"
  add_foreign_key "word_roots", "roots"
  add_foreign_key "word_roots", "words"
  add_foreign_key "word_translations", "translations"
  add_foreign_key "word_translations", "words"
  add_foreign_key "words", "lexemes"
  add_foreign_key "words", "words", column: "origin_word_id"
end
