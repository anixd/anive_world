# == Schema Information
#
# Table name: shares
#
#  id             :bigint           not null, primary key
#  access_level   :integer          default("read"), not null
#  shareable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  shareable_id   :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_shares_on_shareable           (shareable_type,shareable_id)
#  index_shares_on_user_and_shareable  (user_id,shareable_id,shareable_type) UNIQUE
#  index_shares_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Share, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
