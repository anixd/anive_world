# == Schema Information
#
# Table name: words
#
#  id             :bigint           not null, primary key
#  comment        :text
#  definition     :text
#  origin_type    :bigint           default(0)
#  part_of_speech :string
#  transcription  :string
#  type           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  lexeme_id      :bigint           not null
#  origin_word_id :bigint
#
# Indexes
#
#  index_words_on_lexeme_id       (lexeme_id)
#  index_words_on_origin_word_id  (origin_word_id)
#  index_words_on_type            (type)
#
# Foreign Keys
#
#  fk_rails_...  (lexeme_id => lexemes.id)
#  fk_rails_...  (origin_word_id => words.id)
#
class VeltariWord < Word

end
