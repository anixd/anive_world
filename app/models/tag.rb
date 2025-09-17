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