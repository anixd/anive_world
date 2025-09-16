# frozen_string_literal: true

# == Schema Information
#
# Table name: synonym_relations
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  synonym_id :bigint           not null
#  word_id    :bigint           not null
#
# Indexes
#
#  index_synonym_relations_on_synonym_id              (synonym_id)
#  index_synonym_relations_on_word_id                 (word_id)
#  index_synonym_relations_on_word_id_and_synonym_id  (word_id,synonym_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (synonym_id => words.id)
#  fk_rails_...  (word_id => words.id)
#
class SynonymRelation < ApplicationRecord
  belongs_to :word
  belongs_to :synonym, class_name: "Word"
end
