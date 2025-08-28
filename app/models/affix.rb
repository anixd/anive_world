# == Schema Information
#
# Table name: affixes
#
#  id          :bigint           not null, primary key
#  affix_type  :string
#  meaning     :text
#  text        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :bigint           not null
#
# Indexes
#
#  index_affixes_on_language_id                          (language_id)
#  index_affixes_on_text_and_language_id_and_affix_type  (text,language_id,affix_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#
class Affix < ApplicationRecord
  belongs_to :language

  enum affix_type: { prefix: "prefix", suffix: "suffix", infix: "infix" }

end
