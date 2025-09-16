# frozen_string_literal: true

# == Schema Information
#
# Table name: translations
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  language     :string           not null
#  text         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#
# Indexes
#
#  index_translations_on_author_id          (author_id)
#  index_translations_on_discarded_at       (discarded_at)
#  index_translations_on_text_and_language  (text,language) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
class Translation < ApplicationRecord
  include Authored
  include ApostropheNormalizer

  has_many :word_translations, dependent: :destroy
  has_many :words, through: :word_translations
  has_many :word_translations, dependent: :destroy
  has_many :words, through: :word_translations

  validates :text, presence: true, uniqueness: { scope: :language }
  validates :language, presence: true

  private

  def normalize_apostrophes
    normalize_field(:language, rule: :strict)
    normalize_field(:text, rule: :safe)
  end
end
