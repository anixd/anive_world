# frozen_string_literal: true

# == Schema Information
#
# Table name: affixes
#
#  id           :bigint           not null, primary key
#  affix_type   :string
#  discarded_at :datetime
#  meaning      :text
#  published_at :datetime
#  text         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  language_id  :bigint           not null
#
# Indexes
#
#  index_affixes_on_author_id                            (author_id)
#  index_affixes_on_discarded_at                         (discarded_at)
#  index_affixes_on_language_id                          (language_id)
#  index_affixes_on_published_at                         (published_at)
#  index_affixes_on_text_and_language_id_and_affix_type  (text,language_id,affix_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#
class Affix < ApplicationRecord
  include Authored
  include Discard::Model
  include ApostropheNormalizer
  include Publishable
  include IndexableLinks

  has_paper_trail

  belongs_to :language
  has_one :etymology, as: :etymologizable, dependent: :destroy
  accepts_nested_attributes_for :etymology, allow_destroy: true


  enum affix_type: { prefix: "prefix", suffix: "suffix", infix: "infix" }

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
