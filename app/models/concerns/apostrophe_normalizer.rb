# frozen_string_literal: true

module ApostropheNormalizer
  extend ActiveSupport::Concern

  # Регулярное выражение для всех "неправильных" апострофов,
  # включая обратный апостроф (backtick), который используется в Markdown.
  STRICT_APOSTROPHE_REGEX = /[’‘`´ʼ]/.freeze

  # "Безопасное" выражение, которое НЕ включает backtick (`).
  SAFE_APOSTROPHE_REGEX = /[’‘´ʼ]/.freeze # backtick ` is excluded

  included do
    # Этот колбэк будет вызывать метод нормализации, определенный в самой модели
    before_validation :normalize_apostrophes
  end

  # Этот метод должен быть реализован в каждой модели,
  # которая подключает этот concern. Это делает конфигурацию явной.
  def normalize_apostrophes
    raise NotImplementedError, "#{self.class} must implement #normalize_apostrophes"
  end

  private

  def normalize_field(field_name, rule: :safe)
    value = self[field_name]
    return unless value.is_a?(String)

    regex = (rule == :strict) ? STRICT_APOSTROPHE_REGEX : SAFE_APOSTROPHE_REGEX
    normalized_value = value.gsub(regex, "'")

    self[field_name] = normalized_value if value != normalized_value
  end
end
