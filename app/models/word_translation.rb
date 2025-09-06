# == Schema Information
#
# Table name: word_translations
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  translation_id :bigint           not null
#  word_id        :bigint           not null
#
# Indexes
#
#  index_word_translations_on_translation_id              (translation_id)
#  index_word_translations_on_word_id                     (word_id)
#  index_word_translations_on_word_id_and_translation_id  (word_id,translation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (translation_id => translations.id)
#  fk_rails_...  (word_id => words.id)
#
class WordTranslation < ApplicationRecord
  include Authored

  belongs_to :word
  belongs_to :translation
end
