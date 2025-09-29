# frozen_string_literal: true

# == Schema Information
#
# Table name: affixes
#
#  id                :bigint           not null, primary key
#  affix_type        :string
#  discarded_at      :datetime
#  meaning           :text
#  published_at      :datetime
#  slug              :string
#  text              :string
#  transcription     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  affix_category_id :bigint
#  author_id         :bigint           not null
#  language_id       :bigint           not null
#
# Indexes
#
#  index_affixes_on_affix_category_id                    (affix_category_id)
#  index_affixes_on_author_id                            (author_id)
#  index_affixes_on_discarded_at                         (discarded_at)
#  index_affixes_on_language_id                          (language_id)
#  index_affixes_on_published_at                         (published_at)
#  index_affixes_on_slug_and_language_id                 (slug,language_id) UNIQUE WHERE (discarded_at IS NULL)
#  index_affixes_on_text_and_language_id_and_affix_type  (text,language_id,affix_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (affix_category_id => affix_categories.id)
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#
class Affix < ApplicationRecord
  include Authored
  include Discard::Model
  include ApostropheNormalizer
  include Sluggable
  include Publishable
  include IndexableLinks

  has_paper_trail

  sluggable_from :text

  belongs_to :language
  belongs_to :affix_category, optional: true

  has_one :etymology, as: :etymologizable, dependent: :destroy
  has_many :morphemes, as: :morphemable, dependent: :destroy
  has_many :lexemes, through: :morphemes

  accepts_nested_attributes_for :etymology,
                                allow_destroy: true,
                                reject_if: ->(attributes) { attributes['explanation'].blank? }



  enum :affix_type, { prefix: "prefix", suffix: "suffix", infix: "infix" }

  validates :text, uniqueness: { scope: [:language_id, :affix_type], case_sensitive: false }

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
    normalize_field(:method, rule: :safe)
  end
end
