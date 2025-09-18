# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_lower_name  (lower((name)::text)) UNIQUE
#
class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy

  # Валидации
  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: {
              with: /\A[a-zа-я0-9\-_']+\z/,
              message: "can only contain letters, numbers, dash, underscore, or apostrophe"
            }

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.to_s.downcase.strip
  end
end
