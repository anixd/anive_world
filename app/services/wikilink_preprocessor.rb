# frozen_string_literal: true

class WikilinkPreprocessor
  def self.call(text)
    MarkdownPreprocessor.call(text)
  end
end
