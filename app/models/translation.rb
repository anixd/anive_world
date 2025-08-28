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
class Translation < ApplicationRecord
  has_many :word_translations, dependent: :destroy
  has_many :words, through: :word_translations
  has_many :word_translations, dependent: :destroy
  has_many :words, through: :word_translations

  validates :text, presence: true, uniqueness: { scope: :language }
  validates :language, presence: true
end
