# frozen_string_literal: true

# == Schema Information
#
# Table name: words
#
#  id             :bigint           not null, primary key
#  comment        :text
#  definition     :text
#  discarded_at   :datetime
#  origin_type    :bigint           default(0)
#  transcription  :string
#  type           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  author_id      :bigint           not null
#  lexeme_id      :bigint           not null
#  origin_word_id :bigint
#
# Indexes
#
#  index_words_on_author_id       (author_id)
#  index_words_on_discarded_at    (discarded_at)
#  index_words_on_lexeme_id       (lexeme_id)
#  index_words_on_origin_word_id  (origin_word_id)
#  index_words_on_type            (type)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (lexeme_id => lexemes.id)
#  fk_rails_...  (origin_word_id => words.id)
#
class Word < ApplicationRecord
  include Discard::Model
  include Authored
  include ApostropheNormalizer
  include IndexableLinks

  enum origin_type: {
    unspecified: 0,
    inherited: 1,
    neologism: 2,
    borrowed: 3,
    derived: 4
  }, _prefix: :origin

  # enum :origin_type, {:unspecified=>0, :inherited=>1, :neologism=>2, :borrowed=>3, :derived=>4}

  has_paper_trail

  before_validation :set_sti_type, on: :create

  belongs_to :lexeme
  belongs_to :origin_word, class_name: "Word", optional: true
  has_and_belongs_to_many :parts_of_speech, class_name: "PartOfSpeech"
  has_one :etymology, as: :etymologizable, dependent: :destroy
  accepts_nested_attributes_for :etymology, allow_destroy: true

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

  def spelling_with_language
    "#{spelling} (#{language.code})"
  end

  private

  def normalize_apostrophes
    normalize_field(:transcription, rule: :strict)
    normalize_field(:definition, rule: :safe)
    normalize_field(:comment, rule: :safe)
  end

  def set_sti_type
    # `self.type` будет установлен, только если он еще не задан
    self.type ||= "#{lexeme.language.code.capitalize}Word" if lexeme&.language.present?
  end
end
