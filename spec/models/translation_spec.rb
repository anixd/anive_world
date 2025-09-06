# == Schema Information
#
# Table name: translations
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  language     :string           not null
#  text         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#
# Indexes
#
#  index_translations_on_author_id          (author_id)
#  index_translations_on_discarded_at       (discarded_at)
#  index_translations_on_text_and_language  (text,language) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
require 'rails_helper'

RSpec.describe Translation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
