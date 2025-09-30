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

ActiveRecord::Schema[7.2].define(version: 2025_09_29_232016) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "affix_categories", force: :cascade do |t|
    t.bigint "language_id", null: false
    t.bigint "author_id", null: false
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_affix_categories_on_author_id"
    t.index ["language_id", "code"], name: "index_affix_categories_on_language_id_and_code", unique: true
    t.index ["language_id", "name"], name: "index_affix_categories_on_language_id_and_name", unique: true
    t.index ["language_id"], name: "index_affix_categories_on_language_id"
  end

  create_table "affixes", force: :cascade do |t|
    t.string "text"
    t.string "affix_type"
    t.bigint "language_id", null: false
    t.bigint "author_id", null: false
    t.text "meaning"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.string "slug"
    t.bigint "affix_category_id"
    t.string "transcription"
    t.index ["affix_category_id"], name: "index_affixes_on_affix_category_id"
    t.index ["author_id"], name: "index_affixes_on_author_id"
    t.index ["discarded_at"], name: "index_affixes_on_discarded_at"
    t.index ["language_id"], name: "index_affixes_on_language_id"
    t.index ["published_at"], name: "index_affixes_on_published_at"
    t.index ["slug", "language_id"], name: "index_affixes_on_slug_and_language_id", unique: true, where: "(discarded_at IS NULL)"
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
    t.string "life_status"
    t.string "birth_date"
    t.string "death_date"
    t.bigint "parent_location_id"
    t.string "rule_code"
    t.bigint "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "era_id"
    t.integer "absolute_year"
    t.string "display_date"
    t.text "extract"
    t.text "annotation"
    t.tsvector "searchable"
    t.index "type, lower((title)::text)", name: "index_content_entries_on_type_and_lower_title"
    t.index ["absolute_year"], name: "index_content_entries_on_absolute_year"
    t.index ["author_id"], name: "index_content_entries_on_author_id"
    t.index ["discarded_at"], name: "index_content_entries_on_discarded_at"
    t.index ["era_id"], name: "index_content_entries_on_era_id"
    t.index ["language_id"], name: "index_content_entries_on_language_id"
    t.index ["parent_location_id"], name: "index_content_entries_on_parent_location_id"
    t.index ["searchable"], name: "content_entries_searchable_idx", using: :gin
    t.index ["slug"], name: "index_content_entries_on_slug", unique: true, where: "(discarded_at IS NULL)"
    t.index ["type"], name: "index_content_entries_on_type"
  end

  create_table "etymologies", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.text "explanation", null: false
    t.text "comment"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "etymologizable_id"
    t.string "etymologizable_type"
    t.index ["author_id"], name: "index_etymologies_on_author_id"
    t.index ["discarded_at"], name: "index_etymologies_on_discarded_at"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.bigint "parent_language_id"
    t.bigint "author_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_languages_on_author_id"
    t.index ["code"], name: "index_languages_on_code", unique: true
    t.index ["discarded_at"], name: "index_languages_on_discarded_at"
    t.index ["name"], name: "index_languages_on_name", unique: true
    t.index ["parent_language_id"], name: "index_languages_on_parent_language_id"
  end

  create_table "lexemes", force: :cascade do |t|
    t.string "spelling"
    t.bigint "language_id", null: false
    t.bigint "author_id", null: false
    t.string "slug", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.integer "origin_type"
    t.bigint "origin_language_id"
    t.index ["author_id"], name: "index_lexemes_on_author_id"
    t.index ["discarded_at"], name: "index_lexemes_on_discarded_at"
    t.index ["language_id"], name: "index_lexemes_on_language_id"
    t.index ["origin_language_id"], name: "index_lexemes_on_origin_language_id"
    t.index ["published_at"], name: "index_lexemes_on_published_at"
    t.index ["slug", "language_id"], name: "index_lexemes_on_slug_and_language_id", unique: true, where: "(discarded_at IS NULL)"
    t.index ["spelling", "language_id"], name: "index_lexemes_on_spelling_and_language_id", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "morphemes", force: :cascade do |t|
    t.bigint "lexeme_id", null: false
    t.string "morphemable_type", null: false
    t.bigint "morphemable_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lexeme_id", "morphemable_id", "morphemable_type"], name: "index_morphemes_on_lexeme_and_morphemable", unique: true
    t.index ["lexeme_id", "position"], name: "index_morphemes_on_lexeme_id_and_position"
    t.index ["lexeme_id"], name: "index_morphemes_on_lexeme_id"
    t.index ["morphemable_type", "morphemable_id"], name: "index_morphemes_on_morphemable"
    t.index ["morphemable_type", "morphemable_id"], name: "index_morphemes_on_morphemable_type_and_morphemable_id"
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

  create_table "parts_of_speech", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "explanation"
    t.bigint "author_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "language_id", null: false
    t.index ["author_id"], name: "index_parts_of_speech_on_author_id"
    t.index ["code", "language_id"], name: "index_parts_of_speech_on_code_and_language_id", unique: true
    t.index ["discarded_at"], name: "index_parts_of_speech_on_discarded_at"
    t.index ["language_id"], name: "index_parts_of_speech_on_language_id"
  end

  create_table "parts_of_speech_words", id: false, force: :cascade do |t|
    t.bigint "word_id", null: false
    t.bigint "part_of_speech_id", null: false
    t.index ["part_of_speech_id", "word_id"], name: "index_parts_of_speech_words_on_part_of_speech_id_and_word_id"
    t.index ["word_id", "part_of_speech_id"], name: "index_parts_of_speech_words_on_word_id_and_part_of_speech_id"
  end

  create_table "roots", force: :cascade do |t|
    t.string "text"
    t.bigint "language_id", null: false
    t.bigint "author_id", null: false
    t.text "meaning"
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "published_at"
    t.string "slug"
    t.string "transcription"
    t.index ["author_id"], name: "index_roots_on_author_id"
    t.index ["discarded_at"], name: "index_roots_on_discarded_at"
    t.index ["language_id"], name: "index_roots_on_language_id"
    t.index ["published_at"], name: "index_roots_on_published_at"
    t.index ["slug", "language_id"], name: "index_roots_on_slug_and_language_id", unique: true, where: "(discarded_at IS NULL)"
    t.index ["text", "language_id"], name: "index_roots_on_text_and_language_id", unique: true
  end

  create_table "shares", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "shareable_type", null: false
    t.bigint "shareable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "access_level", default: 0, null: false
    t.index ["shareable_type", "shareable_id"], name: "index_shares_on_shareable"
    t.index ["user_id", "shareable_id", "shareable_type"], name: "index_shares_on_user_and_shareable", unique: true
    t.index ["user_id"], name: "index_shares_on_user_id"
  end

  create_table "slug_redirects", force: :cascade do |t|
    t.string "old_slug", null: false
    t.string "sluggable_type", null: false
    t.bigint "sluggable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["old_slug"], name: "index_slug_redirects_on_old_slug"
    t.index ["sluggable_type", "sluggable_id"], name: "index_slug_redirects_on_sluggable"
  end

  create_table "synonym_relations", force: :cascade do |t|
    t.bigint "lexeme_1_id", null: false
    t.bigint "lexeme_2_id", null: false
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lexeme_1_id", "lexeme_2_id"], name: "index_synonym_relations_on_lexeme_1_id_and_lexeme_2_id", unique: true
    t.index ["lexeme_1_id"], name: "index_synonym_relations_on_lexeme_1_id"
    t.index ["lexeme_2_id"], name: "index_synonym_relations_on_lexeme_2_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.string "taggable_type", null: false
    t.bigint "taggable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_type", "taggable_id"], name: "index_taggings_on_tag_and_taggable", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_tags_on_lower_name", unique: true
  end

  create_table "timeline_calendars", force: :cascade do |t|
    t.string "name", null: false
    t.string "epoch_name"
    t.integer "absolute_year_of_epoch", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timeline_eras", force: :cascade do |t|
    t.string "name", null: false
    t.integer "order_index"
    t.integer "start_absolute_year"
    t.integer "end_absolute_year"
    t.bigint "calendar_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_timeline_eras_on_calendar_id"
  end

  create_table "timeline_participations", force: :cascade do |t|
    t.string "role"
    t.bigint "history_entry_id", null: false
    t.string "participant_type", null: false
    t.bigint "participant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["history_entry_id"], name: "index_timeline_participations_on_history_entry_id"
    t.index ["participant_type", "participant_id"], name: "index_timeline_participations_on_participant"
  end

  create_table "translations", force: :cascade do |t|
    t.string "text", null: false
    t.string "language", null: false
    t.bigint "author_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_translations_on_author_id"
    t.index ["discarded_at"], name: "index_translations_on_discarded_at"
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
    t.integer "role", default: 4, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.bigint "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "wikilinks", force: :cascade do |t|
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.string "target_slug", null: false
    t.string "target_type", null: false
    t.string "target_language_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_wikilinks_on_source"
    t.index ["source_type", "source_id"], name: "index_wikilinks_on_source_type_and_source_id"
    t.index ["target_type", "target_slug"], name: "index_wikilinks_on_target_type_and_target_slug"
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
    t.text "comment"
    t.bigint "author_id", null: false
    t.datetime "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_words_on_author_id"
    t.index ["discarded_at"], name: "index_words_on_discarded_at"
    t.index ["lexeme_id"], name: "index_words_on_lexeme_id"
    t.index ["type"], name: "index_words_on_type"
  end

  add_foreign_key "affix_categories", "languages"
  add_foreign_key "affix_categories", "users", column: "author_id"
  add_foreign_key "affixes", "affix_categories"
  add_foreign_key "affixes", "languages"
  add_foreign_key "affixes", "users", column: "author_id"
  add_foreign_key "content_entries", "content_entries", column: "parent_location_id"
  add_foreign_key "content_entries", "languages"
  add_foreign_key "content_entries", "timeline_eras", column: "era_id"
  add_foreign_key "content_entries", "users", column: "author_id"
  add_foreign_key "etymologies", "users", column: "author_id"
  add_foreign_key "languages", "languages", column: "parent_language_id"
  add_foreign_key "languages", "users", column: "author_id"
  add_foreign_key "lexemes", "languages"
  add_foreign_key "lexemes", "languages", column: "origin_language_id"
  add_foreign_key "lexemes", "users", column: "author_id"
  add_foreign_key "morphemes", "lexemes"
  add_foreign_key "notes", "users", column: "author_id"
  add_foreign_key "parts_of_speech", "languages"
  add_foreign_key "parts_of_speech", "users", column: "author_id"
  add_foreign_key "roots", "languages"
  add_foreign_key "roots", "users", column: "author_id"
  add_foreign_key "shares", "users"
  add_foreign_key "synonym_relations", "lexemes", column: "lexeme_1_id"
  add_foreign_key "synonym_relations", "lexemes", column: "lexeme_2_id"
  add_foreign_key "taggings", "tags"
  add_foreign_key "timeline_eras", "timeline_calendars", column: "calendar_id"
  add_foreign_key "timeline_participations", "content_entries", column: "history_entry_id"
  add_foreign_key "translations", "users", column: "author_id"
  add_foreign_key "word_translations", "translations"
  add_foreign_key "word_translations", "words"
  add_foreign_key "words", "lexemes"
  add_foreign_key "words", "users", column: "author_id"
end
