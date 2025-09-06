# == Schema Information
#
# Table name: etymologies
#
#  id           :bigint           not null, primary key
#  comment      :text
#  discarded_at :datetime
#  explanation  :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  word_id      :bigint           not null
#
# Indexes
#
#  index_etymologies_on_author_id     (author_id)
#  index_etymologies_on_discarded_at  (discarded_at)
#  index_etymologies_on_word_id       (word_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (word_id => words.id)
#
class Etymology < ApplicationRecord
  include Discard::Model
  include Authored
  include ApostropheNormalizer

  has_paper_trail

  belongs_to :word

  private

  def normalize_apostrophes
    normalize_field(:comment, rule: :safe)
    normalize_field(:explanation, rule: :safe)
  end
end
