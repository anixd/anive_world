# == Schema Information
#
# Table name: lexemes
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  slug         :string           not null
#  spelling     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  language_id  :bigint           not null
#
# Indexes
#
#  index_lexemes_on_author_id                 (author_id)
#  index_lexemes_on_discarded_at              (discarded_at)
#  index_lexemes_on_language_id               (language_id)
#  index_lexemes_on_slug_and_language_id      (slug,language_id) UNIQUE WHERE (discarded_at IS NULL)
#  index_lexemes_on_spelling_and_language_id  (spelling,language_id) UNIQUE WHERE (discarded_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#
class Lexeme < ApplicationRecord
  include Discard::Model
  include Authored
  include ApostropheNormalizer

  has_paper_trail

  before_validation :generate_slug, on: [:create, :update]

  belongs_to :language

  has_many :words, dependent: :destroy
  accepts_nested_attributes_for :words

  validates :spelling, presence: true, uniqueness: { scope: :language }
  validates :language, presence: true

  def to_param
    slug
  end

  private

  def normalize_apostrophes
    normalize_field(:spelling, rule: :strict)
  end

  def generate_slug
    self.slug = SlugGenerator.call(self.spelling) if self.spelling_changed?
  end
end
