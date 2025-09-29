# frozen_string_literal: true

# == Schema Information
#
# Table name: affix_categories
#
#  id          :bigint           not null, primary key
#  code        :string           not null
#  description :text
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :bigint           not null
#  language_id :bigint           not null
#
# Indexes
#
#  index_affix_categories_on_author_id             (author_id)
#  index_affix_categories_on_language_id           (language_id)
#  index_affix_categories_on_language_id_and_code  (language_id,code) UNIQUE
#  index_affix_categories_on_language_id_and_name  (language_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#
class AffixCategory < ApplicationRecord
  include Authored

  belongs_to :language
  has_many :affixes

  validates :name, presence: true, uniqueness: { scope: :language_id }
  validates :code, presence: true, uniqueness: { scope: :language_id },
            format: { with: /\A[a-z0-9_]+\z/, message: "can only contain lowercase letters, numbers, and underscores" }
end
