# == Schema Information
#
# Table name: affixes
#
#  id           :bigint           not null, primary key
#  affix_type   :string
#  discarded_at :datetime
#  meaning      :text
#  text         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  language_id  :bigint           not null
#
# Indexes
#
#  index_affixes_on_author_id                            (author_id)
#  index_affixes_on_discarded_at                         (discarded_at)
#  index_affixes_on_language_id                          (language_id)
#  index_affixes_on_text_and_language_id_and_affix_type  (text,language_id,affix_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#
require 'rails_helper'

RSpec.describe Affix, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
