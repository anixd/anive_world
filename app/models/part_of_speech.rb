# frozen_string_literal: true

# == Schema Information
#
# Table name: parts_of_speech
#
#  id           :bigint           not null, primary key
#  code         :string           not null
#  discarded_at :datetime
#  explanation  :text
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#  language_id  :bigint           not null
#
# Indexes
#
#  index_parts_of_speech_on_author_id             (author_id)
#  index_parts_of_speech_on_code_and_language_id  (code,language_id) UNIQUE
#  index_parts_of_speech_on_discarded_at          (discarded_at)
#  index_parts_of_speech_on_language_id           (language_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#
class PartOfSpeech < ApplicationRecord
  include Authored
  include Discard::Model

  belongs_to :language
  has_and_belongs_to_many :words
end
