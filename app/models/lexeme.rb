# frozen_string_literal: true

# == Schema Information
#
# Table name: lexemes
#
#  id                 :bigint           not null, primary key
#  discarded_at       :datetime
#  origin_type        :integer
#  published_at       :datetime
#  slug               :string           not null
#  spelling           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :bigint           not null
#  language_id        :bigint           not null
#  origin_language_id :bigint
#
# Indexes
#
#  index_lexemes_on_author_id                 (author_id)
#  index_lexemes_on_discarded_at              (discarded_at)
#  index_lexemes_on_language_id               (language_id)
#  index_lexemes_on_origin_language_id        (origin_language_id)
#  index_lexemes_on_published_at              (published_at)
#  index_lexemes_on_slug_and_language_id      (slug,language_id) UNIQUE WHERE (discarded_at IS NULL)
#  index_lexemes_on_spelling_and_language_id  (spelling,language_id) UNIQUE WHERE (discarded_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (origin_language_id => languages.id)
#
class Lexeme < ApplicationRecord
  include Discard::Model
  include Authored
  include ApostropheNormalizer
  include Sluggable
  include Publishable

  enum origin_type: {
    unspecified: 0,
    inherited: 1,
    neologism: 2,
    borrowed: 3
  }, _prefix: :origin

  has_paper_trail

  sluggable_from :spelling

  belongs_to :language
  belongs_to :origin_language, class_name: "Language", optional: true


  has_many :words, dependent: :destroy
  has_many :morphemes, -> { order(position: :asc) }, dependent: :destroy
  has_many :roots, through: :morphemes, source: :morphemable, source_type: "Root"
  has_many :affixes, through: :morphemes, source: :morphemable, source_type: "Affix"


  accepts_nested_attributes_for :words

  validates :spelling, presence: true, uniqueness: { scope: :language }
  validates :language, presence: true

  scope :search_by_spelling, ->(query) {
    where("spelling ILIKE ?", "%#{sanitize_sql_like(query)}%")
  }

  scope :for_language, ->(language_code) {
    joins(:language).where(languages: { code: language_code })
  }

  private

  def normalize_apostrophes
    normalize_field(:spelling, rule: :strict)
  end
end
