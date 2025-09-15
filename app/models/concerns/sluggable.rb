module Sluggable
  extend ActiveSupport::Concern

  included do
    # `class_attribute` создает атрибут на уровне класса, который корректно наследуется.
    # Это гарантирует, что Article получит настройку :title от ContentEntry.
    class_attribute :slug_source_attribute, instance_writer: false

    has_many :slug_redirects, as: :sluggable, dependent: :destroy
    before_validation :generate_slug_and_redirects
  end

  def to_param
    slug
  end

  private

  def generate_slug_and_redirects
    # 1. Получаем имя поля-источника (например, :title), заданное в модели.
    source_attr = self.class.slug_source_attribute
    return unless source_attr # Если в модели не вызвали sluggable_from, ничего не делаем.

    # 2. Получаем значение этого поля (например, "Новый заголовок статьи").
    source_value = send(source_attr)
    return if source_value.blank?

    # 3. Проверяем, изменилось ли это поле (например, `title_changed?`).
    if send("#{source_attr}_changed?")
      # 4. Если объект уже существует в БД и у него был slug, создаем редирект.
      if persisted? && slug.present?
        # `slug_was` - значение slug до начала изменений.
        slug_redirects.create!(old_slug: slug_was)
      end
      self.slug = SlugGenerator.call(source_value)
    elsif slug.blank?
      # 5. Если это новая запись, slug просто генерируется.
      self.slug = SlugGenerator.call(source_value)
    end
  end

  module ClassMethods
    def sluggable_from(attribute)
      # Теперь этот метод просто и надежно устанавливает наш class_attribute.
      self.slug_source_attribute = attribute
    end
  end
end
