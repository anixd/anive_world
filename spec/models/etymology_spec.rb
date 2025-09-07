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
require 'rails_helper'

RSpec.describe Etymology, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
