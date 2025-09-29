# == Schema Information
#
# Table name: affix_types
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :bigint           not null
#
# Indexes
#
#  index_affix_types_on_language_id  (language_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#
class AffixType < ApplicationRecord
  belongs_to :language
  has_many :affixes

  validates :name, presence: true, uniqueness: { scope: :language_id }
end
