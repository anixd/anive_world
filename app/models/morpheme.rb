# frozen_string_literal: true

# == Schema Information
#
# Table name: morphemes
#
#  id               :bigint           not null, primary key
#  morphemable_type :string           not null
#  position         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  lexeme_id        :bigint           not null
#  morphemable_id   :bigint           not null
#
# Indexes
#
#  index_morphemes_on_lexeme_and_morphemable               (lexeme_id,morphemable_id,morphemable_type) UNIQUE
#  index_morphemes_on_lexeme_id                            (lexeme_id)
#  index_morphemes_on_lexeme_id_and_position               (lexeme_id,position)
#  index_morphemes_on_morphemable                          (morphemable_type,morphemable_id)
#  index_morphemes_on_morphemable_type_and_morphemable_id  (morphemable_type,morphemable_id)
#
# Foreign Keys
#
#  fk_rails_...  (lexeme_id => lexemes.id)
#
class Morpheme < ApplicationRecord
  belongs_to :lexeme
  belongs_to :morphemable, polymorphic: true

  validates :morphemable_id,
            uniqueness: {
              scope: [:lexeme_id, :morphemable_type],
              message: "morpheme is already present in this lexeme"
            },
            if: :disallow_duplicates?

  private

  # TODO: ЗАГЛУШКА: По умолчанию запрещаем дубликаты. В будущем здесь будет проверка системной настройки.
  def disallow_duplicates?
    # !Setting.current.allow_duplicate_morphemes?
    true
  end
end
