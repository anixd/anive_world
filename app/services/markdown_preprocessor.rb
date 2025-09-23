# frozen_string_literal: true

class MarkdownPreprocessor
  # [[SECTION:[LANG:]IDENTIFIER|DISPLAY_TEXT]]
  # 1: section_alias (w, a, h, c...)
  # 2: language_alias (a, d, v...) - опционально, с двоеточием
  # 3: identifier (slug)
  # 4: display_text (опционально)
  WIKILINK_REGEX = /\[\[(\w+):(?:(\w+):)?([^\]|]+)(?:\|([^\]]+))?\]\]/

  def self.call(text, context: :forge)
    return text.to_s if text.to_s.empty?

    text.gsub(WIKILINK_REGEX) do |match|
      section_alias = Regexp.last_match(1)&.downcase
      lang_alias = Regexp.last_match(2)&.downcase
      identifier = Regexp.last_match(3)&.strip
      display_text = Regexp.last_match(4)&.strip

      record = WikilinkResolver.resolve(section_alias, lang_alias, identifier)

      link_text = display_text.presence || identifier
      data_attributes = "data-type=\"#{section_alias}\" data-slug=\"#{identifier}\""
      data_attributes << " data-lang=\"#{lang_alias}\"" if lang_alias.present?


      if record
        # Передаем context в path_for
        href = WikilinkResolver.path_for(record, context: context)
        %(<a href="#{href}" class="wikilink" #{data_attributes}>#{link_text}</a>)
      else
        %(<a href="#" class="wikilink missing" #{data_attributes}>#{link_text}</a>)
      end
    end
  end
end
