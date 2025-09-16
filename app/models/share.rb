# frozen_string_literal: true

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
class Share < ApplicationRecord
  belongs_to :user
  belongs_to :shareable, polymorphic: true

  enum :access_level, { read: 0, write: 1 }
end
