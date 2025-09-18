module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings
  end

  def tags_string
    tags.map(&:name).join(', ')
  end

  def tags_string=(names)
    self.tags = names.to_s.split(/[,|\s]+/).map do |name|
      clean_name = name.strip.gsub(/^#/, '')
      next if clean_name.blank?

      Tag.find_or_create_by(name: clean_name.downcase)
    end.compact
  end
end
