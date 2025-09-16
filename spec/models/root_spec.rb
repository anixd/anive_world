# == Schema Information
#
# Table name: roots
#
#  id           :bigint           not null, primary key
#  discarded_at :datetime
#  meaning      :text
#  published_at :datetime
#  text         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  language_id  :bigint           not null
#
# Indexes
#
#  index_roots_on_author_id             (author_id)
#  index_roots_on_discarded_at          (discarded_at)
#  index_roots_on_language_id           (language_id)
#  index_roots_on_published_at          (published_at)
#  index_roots_on_text_and_language_id  (text,language_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#
require 'rails_helper'

RSpec.describe Root, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
