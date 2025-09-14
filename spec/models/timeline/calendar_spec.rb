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
require 'rails_helper'

RSpec.describe Timeline::Calendar, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
