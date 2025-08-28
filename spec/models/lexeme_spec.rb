# == Schema Information
#
# Table name: lexemes
#
#  id          :bigint           not null, primary key
#  spelling    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :bigint           not null
#
# Indexes
#
#  index_lexemes_on_language_id               (language_id)
#  index_lexemes_on_spelling_and_language_id  (spelling,language_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#
require 'rails_helper'

RSpec.describe Lexeme, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
