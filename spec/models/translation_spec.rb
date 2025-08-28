# == Schema Information
#
# Table name: translations
#
#  id         :bigint           not null, primary key
#  language   :string           not null
#  text       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_translations_on_text_and_language  (text,language) UNIQUE
#
require 'rails_helper'

RSpec.describe Translation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
