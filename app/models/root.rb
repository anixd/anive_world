# == Schema Information
#
# Table name: roots
#
#  id          :bigint           not null, primary key
#  meaning     :text
#  text        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :bigint           not null
#
# Indexes
#
#  index_roots_on_language_id           (language_id)
#  index_roots_on_text_and_language_id  (text,language_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#
class Root < ApplicationRecord
  belongs_to :language
  has_many :word_roots, dependent: :destroy
  has_many :words, through: :word_roots
end
