# frozen_string_literal: true

# == Schema Information
#
# Table name: words
#
#  id            :bigint           not null, primary key
#  comment       :text
#  definition    :text
#  discarded_at  :datetime
#  transcription :string
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  author_id     :bigint           not null
#  lexeme_id     :bigint           not null
#
# Indexes
#
#  index_words_on_author_id     (author_id)
#  index_words_on_discarded_at  (discarded_at)
#  index_words_on_lexeme_id     (lexeme_id)
#  index_words_on_type          (type)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (lexeme_id => lexemes.id)
#
class Word < ApplicationRecord
  include Discard::Model
  include Authored
  include ApostropheNormalizer
  include IndexableLinks

  has_paper_trail

  before_validation :set_sti_type, on: :create

  belongs_to :lexeme

  has_and_belongs_to_many :parts_of_speech, class_name: "PartOfSpeech"
  has_one :etymology, as: :etymologizable, dependent: :destroy

  has_many :word_translations, dependent: :destroy
  has_many :translations, through: :word_translations

  delegate :language, :spelling, to: :lexeme

  accepts_nested_attributes_for :etymology, allow_destroy: true

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
