# frozen_string_literal: true

# == Schema Information
#
# Table name: words
#
#  id             :bigint           not null, primary key
#  comment        :text
#  definition     :text
#  discarded_at   :datetime
#  origin_type    :bigint           default("unspecified")
#  transcription  :string
#  type           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  author_id      :bigint           not null
#  lexeme_id      :bigint           not null
#  origin_word_id :bigint
#
# Indexes
#
#  index_words_on_author_id       (author_id)
#  index_words_on_discarded_at    (discarded_at)
#  index_words_on_lexeme_id       (lexeme_id)
#  index_words_on_origin_word_id  (origin_word_id)
#  index_words_on_type            (type)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (lexeme_id => lexemes.id)
#  fk_rails_...  (origin_word_id => words.id)
#

class DrelenWord < Word
  include Authored

  def self.model_name
    Word.model_name
  end
end
