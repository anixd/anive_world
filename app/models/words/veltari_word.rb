# frozen_string_literal: true

# == Schema Information
#
# Table name: words
#
#  id             :bigint           not null, primary key
#  comment        :text
#  definition     :text
#  discarded_at   :datetime
#  transcription  :string
#  type           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  author_id      :bigint           not null
#  lexeme_id      :bigint           not null
#
# Indexes
#
#  index_words_on_author_id       (author_id)
#  index_words_on_discarded_at    (discarded_at)
#  index_words_on_lexeme_id       (lexeme_id)
#  index_words_on_type            (type)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (lexeme_id => lexemes.id)
#

class VeltariWord < Word
  include Authored

  def self.model_name
    Word.model_name
  end
end
