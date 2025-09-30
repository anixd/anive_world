# frozen_string_literal: true

# == Schema Information
#
# Table name: synonym_relations
#
#  id          :bigint           not null, primary key
#  comment     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  lexeme_1_id :bigint           not null
#  lexeme_2_id :bigint           not null
#
# Indexes
#
#  index_synonym_relations_on_lexeme_1_id                  (lexeme_1_id)
#  index_synonym_relations_on_lexeme_1_id_and_lexeme_2_id  (lexeme_1_id,lexeme_2_id) UNIQUE
#  index_synonym_relations_on_lexeme_2_id                  (lexeme_2_id)
#
# Foreign Keys
#
#  fk_rails_...  (lexeme_1_id => lexemes.id)
#  fk_rails_...  (lexeme_2_id => lexemes.id)
#
class SynonymRelation < ApplicationRecord
  belongs_to :lexeme_1, class_name: 'Lexeme'
  belongs_to :lexeme_2, class_name: 'Lexeme'

  before_validation :order_lexemes

  private

  def order_lexemes
    if lexeme_1_id > lexeme_2_id
      self.lexeme_1_id, self.lexeme_2_id = self.lexeme_2_id, self.lexeme_1_id
    end
  end
end
