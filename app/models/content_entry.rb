# == Schema Information
#
# Table name: content_entries
#
#  id                 :bigint           not null, primary key
#  absolute_year      :integer
#  birth_date         :string
#  body               :text
#  death_date         :string
#  discarded_at       :datetime
#  display_date       :string
#  life_status        :string
#  published_at       :datetime
#  rule_code          :string
#  slug               :string           not null
#  title              :string           not null
#  type               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :bigint           not null
#  era_id             :bigint
#  language_id        :bigint
#  parent_location_id :bigint
#
# Indexes
#
#  index_content_entries_on_absolute_year       (absolute_year)
#  index_content_entries_on_author_id           (author_id)
#  index_content_entries_on_discarded_at        (discarded_at)
#  index_content_entries_on_era_id              (era_id)
#  index_content_entries_on_language_id         (language_id)
#  index_content_entries_on_parent_location_id  (parent_location_id)
#  index_content_entries_on_slug                (slug) UNIQUE WHERE (discarded_at IS NULL)
#  index_content_entries_on_type                (type)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (era_id => timeline_eras.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (parent_location_id => content_entries.id)
#
class ContentEntry < ApplicationRecord
  include Authored
  include Discard::Model

  has_paper_trail

  before_validation :generate_slug, on: %i[create update]

  # for Location
  # belongs_to :parent_location, class_name: "Location", optional: true

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = SlugGenerator.call(title) if title.present? && slug.blank?
  end
end
