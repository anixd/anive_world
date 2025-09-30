# frozen_string_literal: true

# == Schema Information
#
# Table name: notes
#
#  id                 :bigint           not null, primary key
#  body               :text
#  discarded_at       :datetime
#  is_public_for_team :boolean          default(FALSE), not null
#  slug               :string
#  title              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :bigint           not null
#
# Indexes
#
#  index_notes_on_author_id_and_slug  (author_id,slug) UNIQUE WHERE (discarded_at IS NULL)
#  index_notes_on_discarded_at        (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
class Note < ApplicationRecord
  include Authored
  include Discard::Model
  include Sluggable
  # has_paper_trail

  sluggable_from :title

  # TODO: в будущем добавить связь has_many :shares, as: :shareable
  # для гранулярного контроля доступа.

  has_many :note_taggings, dependent: :destroy
  has_many :note_tags, through: :note_taggings

  validates :title, presence: true
  validates :body, presence: true

  def tags_string
    note_tags.map(&:name).join(', ')
  end

  # Setter to process tags from the form
  def tags_string=(names)
    self.note_tags = names.to_s.split(/[,|\s]+/).map do |name|
      clean_name = name.strip.gsub(/^#/, "")
      next if clean_name.blank?

      # Find or create the tag FOR THE NOTE'S AUTHOR
      author.note_tags.find_or_create_by(name: clean_name.downcase)
    end.compact
  end
end
