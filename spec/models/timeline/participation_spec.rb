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
require 'rails_helper'

RSpec.describe Timeline::Participation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
