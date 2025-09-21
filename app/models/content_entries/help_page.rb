class HelpPage < ContentEntry
  # Связь для определения родительской страницы
  belongs_to :parent, class_name: "HelpPage", foreign_key: "parent_location_id", optional: true, inverse_of: :children

  # Связь для получения дочерних страниц
  has_many :children, class_name: "HelpPage", foreign_key: "parent_location_id", dependent: :nullify, inverse_of: :parent

  # Скоуп для выборки только корневых страниц (у которых нет родителя)
  scope :top_level, -> { where(parent_location_id: nil) }
end
