# frozen_string_literal: true

# == Schema Information
#
# Table name: roots
#
#  id            :bigint           not null, primary key
#  discarded_at  :datetime
#  meaning       :text
#  published_at  :datetime
#  slug          :string
#  text          :string
#  transcription :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  author_id     :bigint           not null
#  language_id   :bigint           not null
#
# Indexes
#
#  index_roots_on_author_id             (author_id)
#  index_roots_on_discarded_at          (discarded_at)
#  index_roots_on_language_id           (language_id)
#  index_roots_on_published_at          (published_at)
#  index_roots_on_slug_and_language_id  (slug,language_id) UNIQUE WHERE (discarded_at IS NULL)
#  index_roots_on_text_and_language_id  (text,language_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#
class Root < ApplicationRecord
  include Authored
  include Discard::Model
  include ApostropheNormalizer
  include Sluggable
  include Publishable
  include IndexableLinks

  has_paper_trail

  sluggable_from :text

  belongs_to :language

  has_many :morphemes, as: :morphemable, dependent: :destroy
  has_many :lexemes, through: :morphemes


  has_one :etymology, as: :etymologizable, dependent: :destroy
  accepts_nested_attributes_for :etymology, allow_destroy: true

  validates :text, uniqueness: {
    scope: :language_id,
    case_sensitive: false,
    conditions: -> { kept }
  }

  validates :transcription, allow_blank: true, format: {
    with: /\A[\p{L}\s.'-]*\z/u,
    message: "can only contain Latin letters, spaces, and the characters .'-"
  }

  scope :search_by_text, ->(query) {
    where("text ILIKE ? OR meaning ILIKE ?", "%#{query}%", "%#{query}%")
  }

  scope :for_language, ->(language_code) {
    joins(:language).where(languages: { code: language_code })
  }

  private

  def normalize_apostrophes
    normalize_field(:text, rule: :strict)
    normalize_field(:meaning, rule: :safe)
  end
end
