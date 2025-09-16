# == Schema Information
#
# Table name: wikilinks
#
#  id                   :bigint           not null, primary key
#  source_type          :string           not null
#  target_language_code :string
#  target_slug          :string           not null
#  target_type          :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  source_id            :bigint           not null
#
# Indexes
#
#  index_wikilinks_on_source                       (source_type,source_id)
#  index_wikilinks_on_source_type_and_source_id    (source_type,source_id)
#  index_wikilinks_on_target_type_and_target_slug  (target_type,target_slug)
#
require 'rails_helper'

RSpec.describe Wikilink, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
