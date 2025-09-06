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
require 'rails_helper'

RSpec.describe Etymology, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
