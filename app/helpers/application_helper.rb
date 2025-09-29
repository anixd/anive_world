# frozen_string_literal: true

module ApplicationHelper
  include MarkdownHelper
  include Pagy::Frontend

  def current_search_scope
    # Список контроллеров лингвистического ядра
    linguistic_controllers = %w[
      languages lexemes words roots affixes parts_of_speech affix_categories
      grammar_rules phonology_articles grammar word_building
    ]

    if linguistic_controllers.include?(controller_name)
      "dictionary"
    else
      "lore"
    end
  end
end
