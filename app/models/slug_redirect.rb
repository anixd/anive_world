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
class SlugRedirect < ApplicationRecord
  belongs_to :sluggable, polymorphic: true

  validates :old_slug, presence: true
end
