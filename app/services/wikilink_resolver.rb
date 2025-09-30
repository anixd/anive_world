# frozen_string_literal: true

class WikilinkResolver
  TYPE_ALIASES = {
    "w" => Lexeme, "word" => Lexeme,
    "rt" => Root, "root" => Root,
    "af" => Affix, "affix" => Affix,
    "a" => Article, "article" => Article,
    "h" => HistoryEntry, "history" => HistoryEntry,
    "c" => Character, "character" => Character,
    "l" => Location, "location" => Location,
    "g" => GrammarRule, "grammar" => GrammarRule,
    "p" => PhonologyArticle, "phonology" => PhonologyArticle,
    "hp" => HelpPage, "help" => HelpPage
  }.freeze

  LANGUAGE_ALIASES = {
    "a" => "anike", "anike" => "anike",
    "d" => "drelen", "drelen" => "drelen",
    "v" => "veltari", "veltari" => "veltari"
  }.freeze

  def self.resolve(type_alias, lang_alias, identifier)
    model = TYPE_ALIASES[type_alias&.downcase]
    return nil unless model

    # Шаг 0: Проверяем, не является ли идентификатор старым slug.
    # Это надо сделать ДО всех остальных проверок.
    slug_to_check = SlugGenerator.call(identifier.strip)
    redirect = SlugRedirect.find_by(old_slug: slug_to_check)

    if redirect && redirect.sluggable.is_a?(model)
      return redirect.sluggable
    end

    if model == Lexeme
      lang_code = LANGUAGE_ALIASES[lang_alias&.downcase]
      return nil unless lang_code
      language = Language.find_by(code: lang_code)
      return nil unless language

      record = model.find_by(slug: identifier, language: language)
      record ||= model.find_by(slug: slug_to_check, language: language)
      record ||= model.where("spelling ILIKE ?", identifier).where(language: language).first
      record
    else
      # Цепочка поиска для остального контента
      record = model.find_by(slug: identifier)
      record ||= model.find_by(slug: slug_to_check)
      record ||= model.where("title ILIKE ?", identifier).first
      record
    end
  end

  def self.path_for(record, context: :forge)
    url_parts = if context == :pub
                  build_pub_path(record)
                else
                  build_forge_path(record)
                end

    Rails.application.routes.url_helpers.polymorphic_path(url_parts)
  rescue ActionController::UrlGenerationError, NoMethodError
    "#"
  end

  private

  def self.build_pub_path(record)
    case record
    when Lexeme, Root, Affix
      # Для этих моделей в pub-части URL вложен в язык
      # => /languages/:language_id/dictionary/:id
      [:pub, record.language, record]
    else
      # Для остальных (Article, Character, etc.) URL прямой
      # => /articles/:id
      [:pub, record]
    end
  end

  def self.build_forge_path(record)
    case record
    when Lexeme
      # For a Lexeme, the path is nested under its language
      [:forge, record.language, record]
    when Word
      # A Word's page is its lexeme's page, which is also nested
      [:forge, record.language, record.lexeme]
    when Root, Affix, PartOfSpeech
      # These are also nested under their language
      [:forge, record.language, record]
    else
      # For all other models (Note, Article, etc.), the path is top-level
      [:forge, record]
    end
  end
end
