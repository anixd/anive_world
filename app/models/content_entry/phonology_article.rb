# == Schema Information
#
# Table name: content_entries
#
#  id                 :bigint           not null, primary key
#  birth_date         :string
#  body               :text
#  death_date         :string
#  discarded_at       :datetime
#  life_status        :string
#  published_at       :datetime
#  rule_code          :string
#  slug               :string           not null
#  timeline_position  :integer
#  title              :string           not null
#  type               :string           not null
#  world_date         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :bigint           not null
#  language_id        :bigint
#  parent_location_id :bigint
#
# Indexes
#
#  index_content_entries_on_author_id           (author_id)
#  index_content_entries_on_discarded_at        (discarded_at)
#  index_content_entries_on_language_id         (language_id)
#  index_content_entries_on_parent_location_id  (parent_location_id)
#  index_content_entries_on_slug                (slug) UNIQUE WHERE (discarded_at IS NULL)
#  index_content_entries_on_type                (type)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (parent_location_id => content_entries.id)
#
class PhonologyArticle < ContentEntry
  # Логика для фонологических статей
end
