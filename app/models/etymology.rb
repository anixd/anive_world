# == Schema Information
#
# Table name: etymologies
#
#  id          :bigint           not null, primary key
#  comment     :text
#  explanation :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  word_id     :bigint           not null
#
# Indexes
#
#  index_etymologies_on_word_id  (word_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (word_id => words.id)
#
class Etymology < ApplicationRecord
  belongs_to :word
end
