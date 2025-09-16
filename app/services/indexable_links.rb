# frozen_string_literal: true

module IndexableLinks
  extend ActiveSupport::Concern

  included do
    has_many :wikilinks, as: :source, dependent: :destroy

    after_save :update_wikilinks_index, if: :text_content_changed?
  end

  private

  def update_wikilinks_index
    WikilinkIndexer.call(self)
  end

  # Проверяем, изменилось ли хотя бы одно текстовое поле в модели
  def text_content_changed?
    # Находим все атрибуты модели с типом :text
    text_attributes = self.class.columns
                          .select { |c| c.type == :text }
                          .map(&:name)

    # Проверяем, есть ли изменения хотя бы в одном из них
    (saved_changes.keys & text_attributes).any?
  end
end
