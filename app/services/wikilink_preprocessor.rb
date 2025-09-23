# frozen_string_literal: true

class WikilinkPreprocessor
  def self.call(text, context: :forge)
    MarkdownPreprocessor.call(text, context: context)
  end
end
