# frozen_string_literal: true

# == Schema Information
#
# Table name: note_taggings
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  note_id     :bigint           not null
#  note_tag_id :bigint           not null
#
# Indexes
#
#  index_note_taggings_on_note_id                  (note_id)
#  index_note_taggings_on_note_id_and_note_tag_id  (note_id,note_tag_id) UNIQUE
#  index_note_taggings_on_note_tag_id              (note_tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (note_id => notes.id)
#  fk_rails_...  (note_tag_id => note_tags.id)
#
class NoteTagging < ApplicationRecord
  belongs_to :note
  belongs_to :note_tag
end
