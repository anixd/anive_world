# == Schema Information
#
# Table name: timeline_calendars
#
#  id                     :bigint           not null, primary key
#  absolute_year_of_epoch :integer          not null
#  description            :text
#  epoch_name             :string
#  name                   :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Timeline::Calendar < ApplicationRecord
  has_many :eras, class_name: "Timeline::Era", dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :absolute_year_of_epoch, presence: true, numericality: { only_integer: true }
end
