# == Schema Information
#
# Table name: languages
#
#  id                 :bigint           not null, primary key
#  code               :string           not null
#  description        :text
#  name               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parent_language_id :bigint
#
# Indexes
#
#  index_languages_on_code                (code) UNIQUE
#  index_languages_on_name                (name) UNIQUE
#  index_languages_on_parent_language_id  (parent_language_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_language_id => languages.id)
#
class Language < ApplicationRecord
  belongs_to :parent_language, class_name: "Language", optional: true
  has_many :child_languages, class_name: "Language", foreign_key: "parent_language_id"

  # has_many :lexemes
  # has_many :roots
end
