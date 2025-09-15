# == Schema Information
#
# Table name: etymologies
#
#  id                  :bigint           not null, primary key
#  comment             :text
#  discarded_at        :datetime
#  etymologizable_type :string
#  explanation         :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  author_id           :bigint           not null
#  etymologizable_id   :bigint
#
# Indexes
#
#  index_etymologies_on_author_id     (author_id)
#  index_etymologies_on_discarded_at  (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
class Etymology < ApplicationRecord
  include Discard::Model
  include Authored
  include ApostropheNormalizer
  include IndexableLinks

  has_paper_trail

  belongs_to :etymologizable, polymorphic: true

  private

  def normalize_apostrophes
    normalize_field(:comment, rule: :safe)
    normalize_field(:explanation, rule: :safe)
  end
end
