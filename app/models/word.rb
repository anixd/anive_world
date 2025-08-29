# == Schema Information
#
# Table name: words
#
#  id             :bigint           not null, primary key
#  comment        :text
#  definition     :text
#  origin_type    :bigint           default(0)
#  part_of_speech :string
#  transcription  :string
#  type           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lexeme_id      :bigint           not null
#  origin_word_id :bigint
#
# Indexes
#
#  index_words_on_lexeme_id       (lexeme_id)
#  index_words_on_origin_word_id  (origin_word_id)
#  index_words_on_type            (type)
#
# Foreign Keys
#
#  fk_rails_...  (lexeme_id => lexemes.id)
#  fk_rails_...  (origin_word_id => words.id)
#
class Word < ApplicationRecord
  belongs_to :lexeme
  belongs_to :origin_word, class_name: "Word", optional: true

  has_one :etymology, dependent: :destroy

  has_many :synonym_relations, dependent: :destroy
  has_many :synonyms, through: :synonym_relations, source: :synonym
  has_many :descendant_words, class_name: "Word", foreign_key: "origin_word_id"
  has_many :word_roots, -> { order(position: :asc) }, dependent: :destroy
  has_many :roots, through: :word_roots
  has_many :inverse_synonym_relations, class_name: "SynonymRelation", foreign_key: "synonym_id", dependent: :destroy
  has_many :inverse_synonyms, through: :inverse_synonym_relations, source: :word
  has_many :word_translations, dependent: :destroy
  has_many :translations, through: :word_translations


  delegate :language, :spelling, to: :lexeme

  accepts_nested_attributes_for :etymology, allow_destroy: true

  def all_synonyms
    synonyms + inverse_synonyms
  end
end
