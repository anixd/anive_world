# == Schema Information
#
# Table name: slug_redirects
#
#  id             :bigint           not null, primary key
#  old_slug       :string           not null
#  sluggable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  sluggable_id   :bigint           not null
#
# Indexes
#
#  index_slug_redirects_on_old_slug   (old_slug)
#  index_slug_redirects_on_sluggable  (sluggable_type,sluggable_id)
#
require 'rails_helper'

RSpec.describe SlugRedirect, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
