# == Schema Information
#
# Table name: languages
#
#  id                 :bigint           not null, primary key
#  code               :string           not null
#  description        :text
#  discarded_at       :datetime
#  name               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :bigint           not null
#  parent_language_id :bigint
#
# Indexes
#
#  index_languages_on_author_id           (author_id)
#  index_languages_on_code                (code) UNIQUE
#  index_languages_on_discarded_at        (discarded_at)
#  index_languages_on_name                (name) UNIQUE
#  index_languages_on_parent_language_id  (parent_language_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (parent_language_id => languages.id)
#
require 'rails_helper'

RSpec.describe Language, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
