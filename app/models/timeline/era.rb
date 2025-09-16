# frozen_string_literal: true

# == Schema Information
#
# Table name: timeline_eras
#
#  id                  :bigint           not null, primary key
#  end_absolute_year   :integer
#  name                :string           not null
#  order_index         :integer
#  start_absolute_year :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  calendar_id         :bigint           not null
#
# Indexes
#
#  index_timeline_eras_on_calendar_id  (calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (calendar_id => timeline_calendars.id)
#
class Timeline::Era < ApplicationRecord
  belongs_to :calendar, class_name: "Timeline::Calendar"
  has_many :history_entries

  validates :name, presence: true
  validates :calendar, presence: true
end
