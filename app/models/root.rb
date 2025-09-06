# == Schema Information
#
# Table name: roots
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  meaning      :text
#  text         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  language_id  :bigint           not null
#
# Indexes
#
#  index_roots_on_author_id             (author_id)
#  index_roots_on_discarded_at          (discarded_at)
#  index_roots_on_language_id           (language_id)
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

  has_paper_trail

  belongs_to :language
  has_many :word_roots, dependent: :destroy
  has_many :words, through: :word_roots

  private

  def normalize_apostrophes
    normalize_field(:text, rule: :strict)
    normalize_field(:meaning, rule: :safe)
  end
end
