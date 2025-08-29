# == Schema Information
#
# Table name: notes
#
#  id                 :bigint           not null, primary key
#  body               :text
#  discarded_at       :datetime
#  is_public_for_team :boolean          default(FALSE), not null
#  title              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  author_id          :bigint           not null
#
# Indexes
#
#  index_notes_on_author_id     (author_id)
#  index_notes_on_discarded_at  (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
class Note < ApplicationRecord
  belongs_to :author, class_name: "User"

  # Здесь же в будущем появится связь has_many :shares, as: :shareable
  # для гранулярного контроля доступа.

  validates :title, presence: true
end
