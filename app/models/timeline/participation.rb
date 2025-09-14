# == Schema Information
#
# Table name: timeline_participations
#
#  id               :bigint           not null, primary key
#  participant_type :string           not null
#  role             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  history_entry_id :bigint           not null
#  participant_id   :bigint           not null
#
# Indexes
#
#  index_timeline_participations_on_history_entry_id  (history_entry_id)
#  index_timeline_participations_on_participant       (participant_type,participant_id)
#
# Foreign Keys
#
#  fk_rails_...  (history_entry_id => content_entries.id)
#
class Timeline::Participation < ApplicationRecord
  belongs_to :history_entry
  belongs_to :participant, polymorphic: true

  validates :history_entry, :participant, presence: true
end
