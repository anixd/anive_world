# frozen_string_literal: true

# == Schema Information
#
# Table name: note_tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_note_tags_on_user_id           (user_id)
#  index_note_tags_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class NoteTag < ApplicationRecord
  belongs_to :user

  has_many :note_taggings, dependent: :destroy
  has_many :notes, through: :note_taggings

  validates :name,
            presence: true,
            uniqueness: { scope: :user_id, case_sensitive: false }
end
