# frozen_string_literal: true

# == Schema Information
#
# Table name: word_roots
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  root_id      :bigint           not null
#  word_id      :bigint           not null
#
# Indexes
#
#  index_word_roots_on_author_id            (author_id)
#  index_word_roots_on_discarded_at         (discarded_at)
#  index_word_roots_on_root_id              (root_id)
#  index_word_roots_on_word_id              (word_id)
#  index_word_roots_on_word_id_and_root_id  (word_id,root_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (root_id => roots.id)
#  fk_rails_...  (word_id => words.id)
#
class WordRoot < ApplicationRecord
  include Authored

  belongs_to :word
  belongs_to :root
end
